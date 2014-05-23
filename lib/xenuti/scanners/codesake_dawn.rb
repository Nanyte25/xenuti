# Copyright (C) 2014 Jan Rusnacko
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of the
# MIT license.

require 'json'

class Xenuti::CodesakeDawn
  include Xenuti::StaticAnalyzer

  class Warning < Xenuti::Warning
    def initialize(hash)
      super

      constraints do
        fail unless name.is_a? String
        fail unless %w(critical high medium low info unknown).include? severity
        fail unless priority.is_a? String
        fail unless message.is_a? String
        fail unless remediation.is_a? String
      end
    end
  end

  # Check requirements for running this scanner - throws RuntimeError if any of
  # the requirements are not met. Returns true when requirements are met.
  def self.check_requirements(_config)
    %x(whereis dawn | grep '/')
    fail 'CodesakeDawn not installed.' if $?.exitstatus != 0
    true
  end

  def initialize(cfg)
    super
  end

  def name
    'codesake_dawn'
  end

  def version
    @version ||= %x(dawn -v).match(/\d\.\d\.\d/).to_s
  end

  def run_scan
    fail 'CodesakeDawn is disabled' unless config.codesake_dawn.enabled
    gemfile_lock_path = config.general.source + '/Gemfile.lock'
    fail 'Cannot find Gemfile.lock' unless File.exist?(gemfile_lock_path)

    @start_time = Time.now
    @results = %x(dawn -j #{config.general.source})
    @end_time = Time.now
  end

  def parse_results(json_output)
    report = Xenuti::ScannerReport.new
    JSON.load(json_output.lines.to_a[1])['vulnerabilities'].each do |warning|
      report.warnings << Warning.new(warning)
    end
    report
  end
end
