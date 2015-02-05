# Copyright (C) 2014 Jan Rusnacko
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of the
# MIT license.

require 'logger'
require 'ruby_util/multi_write_io'
require 'json'

class Xenuti::Processor
  attr_accessor :config

  LOG_LEVEL = {
    'fatal' => Logger::FATAL, 'error' => Logger::ERROR,
    'warn' => Logger::WARN, 'info' => Logger::INFO, 'debug' => Logger::DEBUG }

  # Update the content. Backend is specified in content_update part of config.
  def self.content_update(config, report)
    backend = config[:content_update][:backend]
    if backend == 'git'
      Xenuti::ContentUpdate::Git.update(config, report)
    elsif backend == 'bugzilla_flaws'
      Xenuti::ContentUpdate::BugzillaFlaws.update(config, report)
    else
      xfail("Unknown content update backed: #{backend}")
    end
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
      $log.formatter = proc do |severity, datetime, _progname, msg|
        "[#{datetime.strftime('%Y-%m-%d %I:%M:%S.%L')}] #{severity}  #{msg}\n"
      end
      $log.level = LOG_LEVEL[config[:general][:loglevel]]
      at_exit { $log.close }
    end
  end

  # Returns a hash mapping script name to full path.
  # Scripts are discovered in two locations: a) scripts directory bundled with
  # Xenuti and b) custom scripts dir as specified in configuration
  def self.map_script_names_to_paths(config)
    map = {}

    xenuti_scripts_dir = File.join(File.dirname(__FILE__), 'scripts')
    custom_scripts_dir = config[:general][:scriptdir]

    [xenuti_scripts_dir, custom_scripts_dir]. each do |scripts_dir|
      Dir.entries(scripts_dir).each do |file|
        full_file_path = File.join(scripts_dir, file)

        # Skip non-files
        next unless File.file? full_file_path

        # drop the file extension
        script_name = file.gsub(/\.[a-z]+$/,'')

        map[script_name.to_sym] = full_file_path
      end
    end

    map
  end

  def initialize(config)
    @config = config
    self.class.create_reports_dir_unless_exist(@config)
    self.class.initialize_log(@config)
  end

  def run
    report = Xenuti::Report.new
    report.scan_info.start_time = Time.now

    self.class.content_update(@config, report)
    run_scripts(report)

    report.scan_info.end_time = Time.now

    # It is important to first output results, only then save it. If we saved
    # report first, Xenuti::Report.prev_report would return report we just saved
    # as oldest one, which would make report diffed with itself in diff mode
    # (see output_results method).
    result = output_results(report)
    report.save(@config)
    result
  end

  # rubocop:disable MethodLength
  def run_scripts(report)
    script_paths = self.class.map_script_names_to_paths(@config)

    config[:process].each do |script, script_cfg|
      s_path = script_paths[script]

      if s_path.nil?
        $log.error "Path to #{script} unknown."
        $log.info "Known paths: #{script_paths.inspect}"
      else
        # handle special case when relative path is just String (convenience)
        if script_cfg[:relative_path].is_a? String
          script_cfg[:relative_path] = [script_cfg[:relative_path]]
        end

        script_cfg[:relative_path].each do |relpath|
          script_report = new_script_report(script, s_path, script_cfg, relpath)
          execute_script(script, s_path, script_cfg[:args], script_report, relpath)
          report.script_reports << script_report
        end
      end
    end
  end
  # rubocop:enable MethodLength

  def new_script_report(script, full_path, script_cfg, relpath)
    version = %x(#{full_path} -v 2>/dev/null)

    script_report = Xenuti::ScriptReport.new
    script_report.scan_info.script_name = script
    script_report.scan_info.version = version.match(/\A[0-9](.[0-9])*\Z/)
    script_report.scan_info.revision = config[:content_update][:revision]
    script_report.scan_info.relpath = relpath
    script_report.scan_info.args = script_cfg[:args]
    script_report
  end

  # rubocop:disable MethodLength
  def execute_script(script_name, script_path, args, script_report, relpath)
    script_report.scan_info.start_time = Time.now
    filepath = config[:content_update][:source]
    filepath = File.join(filepath, relpath) unless relpath.empty?
    args = args.nil? ? '' : args.strip

    # execute script
    $log.info "[#{script_name}] executing #{script_name} #{args} #{filepath}"
    output = %x(#{script_path} #{args} #{filepath})
    $log.info "[#{script_name}] finished."

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
