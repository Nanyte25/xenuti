# Copyright (C) 2014 Jan Rusnacko
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of the
# MIT license.

class Xenuti::BundlerAudit
  include Xenuti::StaticAnalyzer
  attr_accessor :report

  def self.check_requirements(_config)
    # Verify brakeman is installed
    begin
      require 'bundler/audit/scanner'
    rescue LoadError
      raise 'Could not load BundlerAudit'
    end

    true
  end

  def initialize(cfg)
    super
  end

  def name
    'bundler_audit'
  end

  def version
    @version ||= %x(bundle-audit version).match(/\d\.\d\.\d/).to_s
  end

  def run_scan
    fail 'BundlerAudit is disabled' unless config.bundler_audit.enabled

    gemfile_lock_path = config.general.source + '/Gemfile.lock'
    fail 'Cannot find Gemfile.lock' unless File.exist?(gemfile_lock_path)

    scanner = Bundler::Audit::Scanner.new(config.general.source)
    @start_time = Time.now
    @bundler_audit_results = scanner.scan
    @end_time = Time.now
  end

  def report
    report ||= parse_bundler_audit_results(@bundler_audit_results)

    # Fill in the metadata
    report.scan_info.start_time = @start_time
    report.scan_info.end_time = @end_time
    report.scan_info.duration = @end_time - @start_time
    report.scan_info.scanner_name = name
    report.scan_info.scanner_version = version

    # Make sure the report is sane
    report.check

    report
  end

  def parse_bundler_audit_results(results)
    report = Xenuti::Report.new
    results.each do |warning|
      report.warnings << warning
    end
    report
  end

  def update_database
    # TODO: updates BundlerAudit`s database
    fail NotImplementedError
  end
end
