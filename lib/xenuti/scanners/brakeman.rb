# Copyright (C) 2014 Jan Rusnacko
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of the
# MIT license.

require 'json'

class Xenuti::Brakeman
  include Xenuti::StaticAnalyzer

  class Warning < Xenuti::Warning
    def initialize(hash)
      super

      constraints do
        fail unless warning_type.is_a? String
        fail unless warning_code.is_a? Integer
        fail unless file.is_a? String
        fail unless message.is_a? String
        fail unless %w(High Medium Low).include? confidence
      end
    end
  end

  # Check requirements for running this scanner - throws RuntimeError if any of
  # the requirements are not met. Returns true when requirements are met.
  def self.check_requirements(_config)
    %x(whereis brakeman | grep '/')
    fail 'Brakeman not installed.' if $?.exitstatus != 0
    true
  end

  def initialize(cfg)
    super
  end

  def name
    'brakeman'
  end

  def version
    @version ||= %x(brakeman -v).match(/\d\.\d\.\d/).to_s
  end

  def run_scan
    fail 'Brakeman is disabled' unless config.brakeman.enabled
    @start_time = Time.now
    @results = %x(brakeman -q -f json #{config.general.source})
    @end_time = Time.now
  end

  def parse_results(json_output)
    report = Xenuti::Report.new
    JSON.load(json_output)['warnings'].each do |warning|
      report.warnings << Warning.new(warning)
    end
    report
  end
end
