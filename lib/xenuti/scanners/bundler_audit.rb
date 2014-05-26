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

    # TODO: refactor
    # rubocop:disable CyclomaticComplexity
    def initialize(hash)
      super

      constraints do
        fail unless name.is_a? String
        fail unless version.is_a? String
        fail unless advisory.is_a? String
        fail unless url.is_a? String
        fail unless title.is_a? String
        fail unless solution.is_a? String
        fail unless CRITICALITY.include? criticality
      end
    end
    # rubocop:enable CyclomaticComplexity

    def <=>(other)
      CRITICALITY.index(criticality) <=> CRITICALITY.index(other.criticality)
    end
  end

  def self.check_requirements(_config)
    %x(whereis bundle-audit | grep '/')
    fail 'BundlerAudit not installed.' if $?.exitstatus != 0
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
    fail 'Cannot find Gemfile.lock' unless gemfile?(config.general.source)

    Dir.jumpd(config.general.source) do
      @start_time = Time.now
      @results = %x(bundle-audit)
      @end_time = Time.now
    end
  end

  # rubocop:disable MethodLength
  def parse_results(res)
    report = Xenuti::ScannerReport.new
    res.scan(/Name:.*?Solution:.*?\n/m).each do |w|
      warn_hash = {}
      warn_hash[:name] = w.match(/(?<=Name: ).*?\n/)[0].strip
      warn_hash[:version] = w.match(/(?<=Version: ).*?\n/)[0].strip
      warn_hash[:advisory] = w.match(/(?<=Advisory: ).*?\n/)[0].strip
      warn_hash[:criticality] = w.match(/(?<=Criticality: ).*?\n/)[0].strip
      warn_hash[:url] = w.match(/(?<=URL: ).*?\n/)[0].strip
      warn_hash[:title] = w.match(/(?<=Title: ).*?\n/)[0].strip
      warn_hash[:solution] = w.match(/(?<=Solution: ).*?\n/)[0].strip
      report.warnings << Warning.new(warn_hash)
    end
    report
  end
  # rubocop:enable MethodLength

  def gemfile?(app_path)
    File.exist?(app_path + '/Gemfile.lock')
  end

  def update_database
    %x(bundle-audit update)
    fail 'Failed to update BundlerAudit database' if $?.exitstatus != 0
  end
end
