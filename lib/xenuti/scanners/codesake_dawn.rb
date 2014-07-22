# Copyright (C) 2014 Jan Rusnacko
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of the
# MIT license.

require 'json'

class Xenuti::CodesakeDawn
  include Xenuti::StaticAnalyzer

  class Warning < Xenuti::Warning
    SEVERITY = %w(critical high medium low info unknown)

    def <=>(other)
      SEVERITY.index(severity) <=> SEVERITY.index(other.severity)
    end
  end

  # Check requirements for running this scanner - throws RuntimeError if any of
  # the requirements are not met. Returns true when requirements are met.
  def self.check_requirements(config)
    %x(whereis dawn | grep '/')
    xfail 'CodesakeDawn: could not find executable.' if $?.exitstatus != 0
    config.general.relative_path.each do |relpath|
      gemfile = File.join(config.general.source, relpath, 'Gemfile.lock')
      xfail 'CodesakeDawn: missing Gemfile.lock' unless File.exist?(gemfile)
    end

    $log.info 'CodesakeDawn: check_requirements passed'
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
      config.general.relative_path.each do |relpath|
        app_dir = File.join(config.general.source, relpath)
        xfail "Directory #{app_dir} does not exist" unless Dir.exist? app_dir
      end
    end
    $log.info 'CodesakeDawn: configuration check passed'
    true
  end

  def self.execute_scan(config, app_dir)
    xfail 'CodesakeDawn is disabled' unless config.codesake_dawn.enabled

    $log.info "CodesakeDawn: starting scan of #{app_dir}"
    output = %x(dawn -j #{app_dir})
    $log.info 'CodesakeDawn: scan finished'
    output
  end

  def self.parse_results(json_output)
    report = Xenuti::ScannerReport.new
    JSON.load(json_output.lines.to_a[1])['vulnerabilities'].each do |warn_hash|
      report.warnings << Xenuti::CodesakeDawn::Warning.from_hash(warn_hash)
    end
    report
  end
end
