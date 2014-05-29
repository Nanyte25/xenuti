# Copyright (C) 2014 Jan Rusnacko
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of the
# MIT license.

require 'json'

class Xenuti::CodesakeDawn
  include Xenuti::Scanner

  class Warning < Xenuti::Warning
    SEVERITY = %w(critical high medium low info unknown)

    def <=>(other)
      SEVERITY.index(severity) <=> SEVERITY.index(other.severity)
    end
  end

  # Check requirements for running this scanner - throws RuntimeError if any of
  # the requirements are not met. Returns true when requirements are met.
  def self.check_requirements(_config)
    %x(whereis dawn | grep '/')
    fail 'CodesakeDawn not installed.' if $?.exitstatus != 0
    true
  end

  def self.name
    'codesake_dawn'
  end

  def self.version
    @version ||= %x(dawn -v).match(/\d\.\d\.\d/).to_s
  end

  def self.check_config(config)
    config.verify do
      fail unless general.source.is_a? String
    end
    true
  end

  def self.execute_scan(config)
    fail 'CodesakeDawn is disabled' unless config.codesake_dawn.enabled
    gemfile_lock_path = config.general.source + '/Gemfile.lock'
    fail 'Cannot find Gemfile.lock' unless File.exist?(gemfile_lock_path)

    %x(dawn -j #{config.general.source})
  end

  def self.parse_results(json_output)
    report = Xenuti::ScannerReport.new
    JSON.load(json_output.lines.to_a[1])['vulnerabilities'].each do |warn_hash|
      report.warnings << Xenuti::CodesakeDawn::Warning.from_hash(warn_hash)
    end
    report
  end
end
