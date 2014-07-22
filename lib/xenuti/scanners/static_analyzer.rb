# Copyright (C) 2014 Jan Rusnacko
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of the
# MIT license.

module Xenuti::StaticAnalyzer
  def initialize(cfg)
    @config = cfg
    self.class.check_requirements(@config)
    self.class.check_config(@config)
  end

  def enabled?
    @config[self.class.name][:enabled]
  end

  # rubocop:disable RescueException
  def run_scan(app_dir)
    @start_time = Time.now
    begin
      @output = self.class.execute_scan(@config, app_dir)
    rescue Exception => e
      @exception = e
    end
    @end_time = Time.now
  end
  # rubocop:enable RescueException

  # TODO: refactor
  # rubocop:disable MethodLength
  def scanner_report(relpath)
    if @scanner_report.nil?
      @scanner_report = self.class.parse_results(@output) unless @exception
      @scanner_report ||= Xenuti::ScannerReport.new

      # Fill in the metadata
      @scanner_report.scan_info.relpath = relpath unless relpath.empty?
      @scanner_report.scan_info.start_time = @start_time
      @scanner_report.scan_info.end_time = @end_time
      @scanner_report.scan_info.duration = (@end_time - @start_time).round(2)
      @scanner_report.scan_info.scanner_name = self.class.name
      @scanner_report.scan_info.scanner_version = self.class.version
      @scanner_report.scan_info.exception = @exception if @exception
    end

    @scanner_report
  end
  # rubocop:enable MethodLength

  def save_output(relpath)
    report_dir = Xenuti::Report.reports_dir(@config)
    unless Dir.exist? report_dir
      $log.info("Creating report directory #{report_dir}")
      FileUtils.mkdir_p report_dir
    end
    out = self.class.name
    out << '_' + relpath unless relpath.empty?
    out = File.join(report_dir, out + '_out')
    $log.info("#{self.class.to_s.split('::').last}: writing output to #{out}")
    File.open(out, 'w+') do |file|
      file.write(@output)
    end
  end
end
