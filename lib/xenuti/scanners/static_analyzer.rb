# Copyright (C) 2014 Jan Rusnacko
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of the
# MIT license.

module Xenuti::StaticAnalyzer
  attr_accessor :config

  def initialize(cfg)
    @config = cfg
    self.class.check_requirements(@config)
    check_config
  end

  def enabled?
    config[name][:enabled]
  end

  def check_config
    config.verify do
      fail unless general.source.is_a? String
    end
    true
  end

  def report
    if @report.nil?
      @report = parse_results(@results)

      # Fill in the metadata
      @report.scan_info.start_time = @start_time
      @report.scan_info.end_time = @end_time
      @report.scan_info.duration = (@end_time - @start_time).round(2)
      @report.scan_info.scanner_name = name
      @report.scan_info.scanner_version = version
    end

    @report
  end
end
