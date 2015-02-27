# Copyright (C) 2014 Jan Rusnacko
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of the
# MIT license.

require 'logger'
require 'ruby_util/multi_write_io'
require 'json'
require 'open3'

class Xenuti::Processor
  attr_accessor :config

  LOG_LEVEL = {
    'fatal' => Logger::FATAL, 'error' => Logger::ERROR,
    'warn' => Logger::WARN, 'info' => Logger::INFO, 'debug' => Logger::DEBUG }

  # Update the content. Backend is specified in content_update part of config.
  def self.content_update(config, backends_paths)
    backend_name = config[:content_update][:backend]
    backend_path = backends_paths[backend_name]
    args = config[:content_update][:args].strip unless config[:content_update][:args].nil?
    workdir = config[:general][:workdir].strip

    # Fail if we don`t know path to the specified backend
    if backend_path.nil?
      $log.error "Path to #{backend_name.inspect} unknown"
      $log.error "Known paths: #{backends_paths.inspect}"
      xfail("Could not finish content update.")
    end

    $log.info "Executing: #{backend_path} #{args} #{workdir}"
    json_out = ''
    Open3.popen3("#{backend_path} #{args} #{workdir}") do |i, o, e|

      # The goal of following is to stream output from stderr of the script
      # to out logger. We could just check: until e.eof? ... but trouble is
      # eof? method might block. To get around this we execute e.eof? with 
      # timeout and assume end of file when timeout expires (e.eof? blocked)
      e_eof = nil
      begin
        Timeout::timeout(5) { e_eof = e.eof? }
      rescue Timeout::Error
        e_eof = true
      end

      until e_eof
        err = e.gets.strip
        $log.info(backend_name) { err }
        begin
          Timeout::timeout(5) { e_eof = e.eof? }
        rescue Timeout::Error
          e_eof = true
        end
      end
      
      json_out = o.read
    end

    return JSON.load json_out
  end

  # rubocop:disable MethodLength
  def self.run_scripts(config, source, report, script_paths)

    config[:process].each do |script, script_cfg|
      s_path = script_paths[script]

      if s_path.nil?
        $log.error "Path to #{script.inspect} unknown."
        $log.error "Known paths: #{script_paths.inspect}"
      else
        # handle special case when relative path is just String (convenience)
        if script_cfg[:relative_path].is_a? String
          script_cfg[:relative_path] = [script_cfg[:relative_path]]
        end

        script_cfg[:relative_path].each do |relpath|
          fullpath = source
          fullpath = File.join(fullpath, relpath) unless relpath.empty?
          script_report = new_script_report(script, s_path, script_cfg, relpath)
          execute_script(script, s_path, script_cfg[:args], script_report, fullpath)
          report['script_reports'] << script_report
        end
      end
    end
  end
  # rubocop:enable MethodLength

  # rubocop:disable MethodLength
  def self.execute_script(script_name, script_path, args, script_report, fullpath)
    script_report.scan_info.start_time = Time.now
    args = args.nil? ? '' : args.strip

    # execute script
    $log.info "Executing #{script_path} #{args} #{fullpath}"
    output = ''
    Open3.popen3("#{script_path} #{args} #{fullpath}") do |i, o, e|

      # The goal of following is to stream output from stderr of the script
      # to out logger. We could just check: until e.eof? ... but trouble is
      # eof? method might block. To get around this we execute e.eof? with 
      # timeout and assume end of file when timeout expires (e.eof? blocked)
      e_eof = nil
      begin
        Timeout::timeout(5) { e_eof = e.eof? }
      rescue Timeout::Error
        e_eof = true
      end

      until e_eof
        err = e.gets.strip
        $log.info(script_name) { err }
        begin
          Timeout::timeout(5) { e_eof = e.eof? }
        rescue Timeout::Error
          e_eof = true
        end
      end

      output = o.read
    end

    # parse (hopefully) JSON output
    begin
      script_report.messages = JSON.parse output
    rescue JSON::ParserError => e
      $log.error "[#{script_name}] Could not parse JSON output from script !"
      script_report.scan_info.exception = e
    end

    script_report.scan_info.end_time = Time.now
    script_report
  end
  # rubocop:enable MethodLength

  def self.new_script_report(script, full_path, script_cfg, relpath)
    version = %x(#{full_path} -v 2>/dev/null)

    script_report = Xenuti::ScriptReport.new
    script_report['scan_info']['script_name'] = script
    script_report['scan_info']['version'] = version.match(/\A[0-9](.[0-9])*\Z/).to_s
    script_report['scan_info']['relpath'] = relpath
    script_report['scan_info']['args'] = script_cfg[:args]
    script_report
  end

  # Creates reports dir if it does not exist yet, NOOP otherwise
  def self.create_reports_dir_unless_exist(config)
    reports_dir = Xenuti::Report.reports_dir(config)
    FileUtils.mkdir_p reports_dir unless Dir.exist?(reports_dir)
  end

  # Initialize $log variable with logger
  def self.initialize_log(config)
    unless $log
      logfile_path = File.join(Xenuti::Report.reports_dir(config), 'xenuti.log')

      # Targets is array of IO objects to write logs to
      targets = [File.new(logfile_path, 'w+')]

      # Unless :quiet was set, also write to STDOUT
      targets << STDOUT unless config[:general][:quiet]

      $log = ::Logger.new(MultiWriteIO.new(*targets))
      $log.formatter = proc do |severity, datetime, progname, msg|
        fmt = "[#{datetime.strftime('%Y-%m-%d %I:%M:%S.%L')}] #{severity}"
        fmt << " [#{progname}]" unless progname.nil?
        fmt << " #{msg}\n"
      end
      $log.level = LOG_LEVEL[config[:general][:loglevel]]
      at_exit { $log.close }
    end
  end

  # Returns a hash mapping script and backend names to full paths.
  # Scripts are discovered in two locations: a) scripts directory bundled with
  # Xenuti and b) custom scripts dir as specified in configuration
  # Same goes for backends.
  #
  # Hash in format {:scripts => {'name' => 'path' ..}, :backends => {..}} is
  # returned
  #
  # Todo: REFACTOR
  def self.map_names_to_paths(config)
    map = {:scripts => {}, :backends => {}}
    general = config[:general]

    # Array of directories to crawl looking for scripts
    script_crawl = []
    script_crawl << File.join(File.dirname(__FILE__), 'scripts')
    if !general[:scriptdir].nil? && Dir.exist?(general[:scriptdir])
      script_crawl << general[:scriptdir] 
    end

    # Array of directories to crawl looking for backends
    backend_crawl = []
    backend_crawl << File.join(File.dirname(__FILE__), 'backends')
    if !general[:backenddir].nil? && Dir.exist?(general[:backenddir])
      backend_crawl << general[:backenddir]
    end

    script_crawl.each do |scripts_dir|
      Dir.entries(scripts_dir).each do |file|
        full_file_path = File.join(scripts_dir, file)

        # Skip non-files
        next unless File.file? full_file_path

        # drop the file extension
        script_name = file.gsub(/\.[a-z]+$/,'')

        map[:scripts][script_name] = full_file_path
      end
    end

    backend_crawl.each do |scripts_dir|
      Dir.entries(scripts_dir).each do |file|
        full_file_path = File.join(scripts_dir, file)

        # Skip non-files
        next unless File.file? full_file_path

        # drop the file extension
        script_name = file.gsub(/\.[a-z]+$/,'')

        map[:backends][script_name] = full_file_path
      end
    end

    map
  end

  def initialize(config)
    @config = config
    @names_to_paths = self.class.map_names_to_paths(@config)
    self.class.create_reports_dir_unless_exist(@config)
    self.class.initialize_log(@config)
  end

  def run
    report = Xenuti::Report.new
    report['scan_info']['start_time'] = Time.now

    output_h = self.class.content_update(@config, @names_to_paths[:backends])
    source = output_h['source']
    self.class.run_scripts(@config, source, report, @names_to_paths[:scripts])

    report['scan_info']['end_time'] = Time.now

    # It is important to first output results, only then save it. If we saved
    # report first, Xenuti::Report.prev_report would return report we just saved
    # as oldest one, which would make report diffed with itself in diff mode
    # (see output_results method).
    result = output_results(report)
    report.save(@config)
    result
  end



  def output_results(report)
    report.diff!(config, Xenuti::Report.prev_report(config)) \
      if Xenuti::Report.prev_report(config)
    formatted = report.formatted(config)
    puts formatted unless config[:general][:quiet]
    if config[:report][:send_mail]
      Xenuti::ReportSender.new(config).send(formatted)
    end
    report
  end
end
