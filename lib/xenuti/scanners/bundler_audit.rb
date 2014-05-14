# Copyright (C) 2014 Jan Rusnacko
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of the
# MIT license.

class Xenuti::BundlerAudit
  include Xenuti::StaticAnalyzer
  attr_accessor :results

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

  def run_scan
    fail 'BundlerAudit is disabled' unless config.bundler_audit.enabled
    gemfile_lock_path = config.general.source + '/Gemfile.lock'
    fail 'Cannot find Gemfile.lock' unless File.exist?(gemfile_lock_path)

    scanner = Bundler::Audit::Scanner.new(config.general.source)
    @results = scanner.scan
  end

  def report
    report = ''
    @results.each { |r| report << r.to_s + "\n" }
    report
  end
end
