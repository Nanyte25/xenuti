# Copyright (C) 2014 Jan Rusnacko
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of the
# MIT license.

require 'ruby_util/dir'

class Xenuti::BundlerAudit
  include Xenuti::Scanner

  class Warning < Xenuti::Warning
    CRITICALITY = %w(High Medium Low Unknown)

    def <=>(other)
      CRITICALITY.index(criticality) <=> CRITICALITY.index(other.criticality)
    end
  end

  def self.check_requirements(_config)
    %x(whereis bundle-audit | grep '/')
    fail 'BundlerAudit not installed.' if $?.exitstatus != 0
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
      fail unless general.source.is_a? String
    end
    true
  end

  def self.execute_scan(config)
    fail 'BundlerAudit is disabled' unless config.bundler_audit.enabled
    gemfile_lock_path = config.general.app_dir + '/Gemfile.lock'
    fail 'Cannot find Gemfile.lock' unless File.exist?(gemfile_lock_path)

    update_database
    Dir.jumpd(config.general.app_dir) do
      return %x(bundle-audit)
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
    %x(bundle-audit update &>/dev/null)
    fail 'Failed to update BundlerAudit database' if $?.exitstatus != 0
  end
end
