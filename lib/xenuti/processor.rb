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

  def initialize(config)
    @config = config
    reports_dir = Xenuti::Report.reports_dir(config)
    FileUtils.mkdir_p reports_dir unless Dir.exist?(reports_dir)
    initialize_log
  end

  def initialize_log
    unless $log
      logfile_path = File.join(Xenuti::Report.reports_dir(config), 'xenuti.log')
      targets = [File.new(logfile_path, 'w+')]
      targets << STDOUT unless config[:general][:quiet]
      $log = ::Logger.new(MultiWriteIO.new(*targets))
      $log.formatter = proc do |severity, datetime, _progname, msg|
        "[#{datetime.strftime('%Y-%m-%d %I:%M:%S.%L')}] #{severity}  #{msg}\n"
      end
      $log.level = LOG_LEVEL[config[:general][:loglevel]]
      at_exit { $log.close }
    end
  end

  def run
    report = Xenuti::Report.new
    report.scan_info.start_time = Time.now

    content_update(report)
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

  def content_update(report)
    backend = config[:content_update][:backend]
    if backend == 'git'
      Xenuti::ContentUpdate::Git.update(config, report)
    elsif backend == 'bugzilla_flaws'
      Xenuti::ContentUpdate::BugzillaFlaws.update(config, report)
    else
      xfail("Unknown content update backed: #{backend}")
    end
  end

  # rubocop:disable MethodLength
  def run_scripts(report)
    config[:process].each do |script, script_cfg|
      if Xenuti::SCRIPTS[script.to_sym].nil?
        $log.error "Path to #{script} unknown."
      else
        if script_cfg[:relative_path].is_a? String
          script_cfg[:relative_path] = [script_cfg[:relative_path]]
        end
        script_cfg[:relative_path].each do |relpath|
          script_report = new_script_report(script, script_cfg, relpath)
          execute_script(script, script_cfg[:args], script_report, relpath)
          report.script_reports << script_report
        end
      end
    end
  end
  # rubocop:enable MethodLength

  def new_script_report(script, script_cfg, relpath)
    version = %x(#{Xenuti::SCRIPTS[script]} -v 2>/dev/null)

    script_report = Xenuti::ScriptReport.new
    script_report.scan_info.script_name = script
    script_report.scan_info.version = version.match(/\A[0-9](.[0-9])*\Z/)
    script_report.scan_info.revision = config[:content_update][:revision]
    script_report.scan_info.relpath = relpath
    script_report.scan_info.args = script_cfg[:args]
    script_report
  end

  # rubocop:disable MethodLength
  def execute_script(script, args, script_report, relpath)
    script_report.scan_info.start_time = Time.now
    filepath = config[:content_update][:source]
    filepath = File.join(filepath, relpath) unless relpath.empty?
    args = args.nil? ? '' : args.strip

    # execute script
    $log.info "[#{script}] executing #{script} #{args} #{filepath}"
    output = %x(#{Xenuti::SCRIPTS[script]} #{args} #{filepath})
    $log.info "[#{script}] finished."

    # parse (hopefully) JSON output
    begin
      script_report.messages = JSON.parse output
    rescue JSON::ParserError => e
      $log.error "[#{script}] Could not parse JSON output from script !"
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
