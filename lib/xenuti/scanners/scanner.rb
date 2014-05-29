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

  def run_scan
    @start_time = Time.now
    @output = self.class.execute_scan(@config)
    @end_time = Time.now
  end

  def report
    if @report.nil?
      @report = self.class.parse_results(@output)

      # Fill in the metadata
      @report.scan_info.start_time = @start_time
      @report.scan_info.end_time = @end_time
      @report.scan_info.duration = (@end_time - @start_time).round(2)
      @report.scan_info.scanner_name = self.class.name
      @report.scan_info.scanner_version = self.class.version
    end

    @report
  end
end
