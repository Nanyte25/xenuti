# Copyright (C) 2014 Jan Rusnacko
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of the
# MIT license.

require 'ruby_util/dir'

class Xenuti::BundlerAudit
  include Xenuti::StaticAnalyzer

  class Warning < Xenuti::Warning
    CRITICALITY = %w(High Medium Low Unknown)

    def <=>(other)
      CRITICALITY.index(criticality) <=> CRITICALITY.index(other.criticality)
    end
  end

  # Check requirements for running this scanner - throws RuntimeError if any of
  # the requirements are not met. Returns true when requirements are met.
  def self.check_requirements(config)
    %x(whereis bundle-audit | grep '/')
    xfail 'BundlerAudit: could not find executable.' if $?.exitstatus != 0
    config.general.relative_path.each do |relpath|
      gemfile = File.join(config.general.source, relpath, 'Gemfile.lock')
      xfail 'BundlerAudit: missing Gemfile.lock' unless File.exist?(gemfile)
    end

    $log.info 'BundlerAudit: check_requirements passed'
    true
  end

  def self.name
    'bundler_audit'
  end

  def self.version
    @version ||= %x(bundle-audit version).match(/\d\.\d\.\d/).to_s
  end

  def self.check_config(config)
    config.verify do
      config.general.relative_path.each do |relpath|
        app_dir = File.join(config.general.source, relpath)
        xfail "Directory #{app_dir} does not exist" unless Dir.exist? app_dir
      end
    end
    $log.info 'BundlerAudit: configuration check passed'
    true
  end

  def self.execute_scan(config, app_dir)
    xfail 'BundlerAudit is disabled' unless config.bundler_audit.enabled

    update_database
    Dir.jumpd(app_dir) do
      $log.info "BundlerAudit: starting scan of #{app_dir}"
      output = %x(bundle-audit)
      $log.info 'BundlerAudit: scan finished'
      return output
    end
  end

  # rubocop:disable MethodLength
  def self.parse_results(output)
    report = Xenuti::ScannerReport.new
    output.scan(/Name:.*?Solution:.*?\n/m).each do |w|
      warn_hash = {}
      warn_hash[:name] = w.match(/(?<=Name: ).*?\n/)[0].strip
      warn_hash[:version] = w.match(/(?<=Version: ).*?\n/)[0].strip
      warn_hash[:advisory] = w.match(/(?<=Advisory: ).*?\n/)[0].strip
      warn_hash[:criticality] = w.match(/(?<=Criticality: ).*?\n/)[0].strip
      warn_hash[:url] = w.match(/(?<=URL: ).*?\n/)[0].strip
      warn_hash[:title] = w.match(/(?<=Title: ).*?\n/)[0].strip
      warn_hash[:solution] = w.match(/(?<=Solution: ).*?\n/)[0].strip
      report.warnings << Xenuti::BundlerAudit::Warning.from_hash(warn_hash)
    end
    report
  end
  # rubocop:enable MethodLength

  def self.update_database
    $log.info 'BundlerAudit: updating database'
    %x(bundle-audit update &>/dev/null)
    xfail 'BundlerAudit: Failed to update database' if $?.exitstatus != 0
  end
end
