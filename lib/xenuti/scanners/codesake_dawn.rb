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
  def self.check_requirements(config)
    %x(whereis dawn | grep '/')
    xfail 'CodesakeDawn: could not find executable.' if $?.exitstatus != 0
    gemfile = config.general.app_dir + '/Gemfile.lock'
    xfail 'CodesakeDawn: missing Gemfile.lock' unless File.exist?(gemfile)

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
      unless Dir.exist? config.general.app_dir
        xfail "Directory #{config.general.appdir} does not exist"
      end
    end
    $log.info 'CodesakeDawn: configuration check passed'
    true
  end

  def self.execute_scan(config)
    xfail 'CodesakeDawn is disabled' unless config.codesake_dawn.enabled

    $log.info 'CodesakeDawn: starting scan'
    output = %x(dawn -j #{config.general.app_dir})
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
