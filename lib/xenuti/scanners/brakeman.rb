# Copyright (C) 2014 Jan Rusnacko
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of the
# MIT license.

require 'json'

class Xenuti::Brakeman
  include Xenuti::Scanner

  class Warning < Xenuti::Warning
    CONFIDENCE = %w(High Medium Weak)

    def <=>(other)
      CONFIDENCE.index(confidence) <=> CONFIDENCE.index(other.confidence)
    end
  end

  # Check requirements for running this scanner - throws RuntimeError if any of
  # the requirements are not met. Returns true when requirements are met.
  def self.check_requirements(_config)
    %x(whereis brakeman | grep '/')
    fail 'Brakeman not installed.' if $?.exitstatus != 0
    true
  end

  def self.name
    'brakeman'
  end

  def self.version
    @version ||= %x(brakeman -v).match(/\d\.\d\.\d/).to_s
  end

  def self.check_config(config)
    config.verify do
      fail unless general.source.is_a? String
    end
    true
  end

  def self.execute_scan(config)
    fail 'Brakeman is disabled' unless config.brakeman.enabled
    %x(brakeman -q -f json #{config.general.app_dir})
  end

  def self.parse_results(json_output)
    report = Xenuti::ScannerReport.new
    JSON.load(json_output)['warnings'].each do |warn_hash|
      report.warnings << Xenuti::Brakeman::Warning.from_hash(warn_hash)
    end
    report
  end
end
