# Copyright (C) 2014 Jan Rusnacko
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of the
# MIT license.

require 'xenuti/repository'

class Xenuti::Processor
  attr_accessor :config

  STATIC_ANALYZERS = [
    Xenuti::Brakeman, Xenuti::CodesakeDawn, Xenuti::BundlerAudit]

  def initialize(config)
    @config = config
  end

  def run
    report = Xenuti::Report.new
    report.scan_info.start_time = Time.now

    check_requirements
    checkout_code
    run_static_analysis(report)

    report.scan_info.end_time = Time.now
    output_results(report)
  end

  def check_requirements
    STATIC_ANALYZERS.each do |analyzer|
      analyzer.check_requirements(config)
    end
  end

  def checkout_code
    Xenuti::Repository.fetch_source(config, config.general.tmpdir + '/source')
  end

  def run_static_analysis(report)
    STATIC_ANALYZERS.each do |klass|
      analyzer = klass.new(config)
      if analyzer.enabled?
        analyzer.run_scan
        report.scanner_reports << analyzer.report
      end
    end
  end

  def output_results(report)
    formatted = report.formatted(config)
    puts formatted unless config.general.quiet
    Xenuti::ReportSender.new(config).send(formatted) if config.smtp.enabled
  end
end
