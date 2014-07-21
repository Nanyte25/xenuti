# Copyright (C) 2014 Jan Rusnacko
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of the
# MIT license.

module Xenuti::Scanner
  def initialize(cfg)
    @config = cfg
    self.class.check_requirements(@config)
    self.class.check_config(@config)
  end

  def enabled?
    @config[self.class.name][:enabled]
  end

  # rubocop:disable RescueException
  def run_scan
    @start_time = Time.now
    begin
      @output = self.class.execute_scan(@config)
    rescue Exception => e
      @exception = e
    end
    @end_time = Time.now
  end
  # rubocop:enable RescueException

  # TODO: refactor
  # rubocop:disable MethodLength
  def scanner_report
    if @scanner_report.nil?
      @scanner_report = self.class.parse_results(@output) unless @exception
      @scanner_report ||= Xenuti::ScannerReport.new

      # Fill in the metadata
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

  def save_output
    report_dir = Xenuti::Report.reports_dir(@config)
    unless Dir.exist? report_dir
      $log.info("Creating report directory #{report_dir}")
      FileUtils.mkdir_p report_dir
    end
    filename = File.join(report_dir, self.class.name + '_output')
    $log.info("#{self.class.name}: writing scan output to #{filename}")
    File.open(filename, 'w+') do |file|
      file.write(@output)
    end
  end
end
