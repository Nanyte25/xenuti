# Copyright (C) 2014 Jan Rusnacko
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of the
# MIT license.

require 'brakeman'
require 'brakeman/version'

class Xenuti::Brakeman
  include Xenuti::StaticAnalyzer
  attr_accessor :tracker

  # Check requirements for running this scanner - throws RuntimeError if any of
  # the requirements are not met. Returns true when requirements are met.
  def self.check_requirements(_config)
    true
  end

  def initialize(cfg)
    super
    process_config
  end

  def name
    'brakeman'
  end

  def version
    Brakeman::Version
  end

  def run_scan
    fail 'Brakeman is disabled' unless config.brakeman.enabled
    @tracker = Brakeman.run config.brakeman.options
  end

  def report
    tracker.report
  end

  def process_config
    # Set app_path for static analyzer to the directory where we checked-out
    # the code
    config.brakeman.options ||= {}
    config.brakeman.options.app_path = config.general.source
  end
end
