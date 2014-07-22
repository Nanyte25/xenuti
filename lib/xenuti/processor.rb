# Copyright (C) 2014 Jan Rusnacko
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of the
# MIT license.

require 'xenuti/repository'
require 'logger'
require 'ruby_util/multi_write_io'

class Xenuti::Processor
  attr_accessor :config

  STATIC_ANALYZERS = [
    Xenuti::Brakeman, Xenuti::CodesakeDawn, Xenuti::BundlerAudit]

  ACTIVE_SCANNERS = []

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
      targets << STDOUT unless config.general.quiet
      $log = ::Logger.new(MultiWriteIO.new(*targets))
      $log.formatter = proc do |severity, datetime, _progname, msg|
        "[#{datetime.strftime('%Y-%m-%d %I:%M.%L')}] #{severity}  #{msg}\n"
      end
      $log.level = LOG_LEVEL[config.general.loglevel]
      at_exit { $log.close }
    end
  end

  def run
    report = Xenuti::Report.new
    report.scan_info.start_time = Time.now

    checkout_code(report)
    run_static_analysis(report)
    run_active_scanners(report)

    report.scan_info.end_time = Time.now
    # It is important to first output results, only then save it. If we saved
    # report first, Xenuti::Report.prev_report would return report we just saved
    # as oldest one, which would make report diffed with itself in diff mode
    # (see output_results method).
    result = output_results(report)
    report.save(@config)
    result
  end

  def check_requirements
    STATIC_ANALYZERS.each do |analyzer|
      analyzer.check_requirements(config) if config[analyzer.name][:enabled]
    end
  end

  def checkout_code(report)
    Xenuti::Repository.fetch_source(config, config.general.workdir + '/source')
    report.scan_info.revision = config.general.revision
  end

  def run_static_analysis(report)
    # Run only enabled analyzers
    STATIC_ANALYZERS.select { |a| @config[a.name][:enabled] }.each do |klass|
      @config.general.relative_path.each do |relpath|
        scanner = klass.new(config)
        scanner.run_scan(File.join(config.general.source, relpath))
        report.scanner_reports << scanner.scanner_report(relpath)
        scanner.save_output(relpath)
      end
    end
  end

  def run_active_scanners(report)
    Xenuti::Deployer.check_requirements(@config)
    ACTIVE_SCANNERS.each do |klass|
      if @config[klass.name][:enabled]
        scanner = klass.new(config)
        xfail 'Failed to deploy' unless Xenuti::Deployer.deploy(config)
        scanner.run_scan
        report.scanner_reports << scanner.scanner_report
        xfail 'Failed to cleanup' unless Xenuti::Deployer.cleanup(config)
      end
    end
  end

  def output_results(report)
    report = Xenuti::Report.diff(Xenuti::Report.prev_report(@config), report) \
      if @config.general.diff && Xenuti::Report.prev_report(@config)
    formatted = report.formatted(config)
    puts formatted unless @config.general.quiet
    Xenuti::ReportSender.new(config).send(formatted) if @config.smtp.enabled
    report
  end
end
