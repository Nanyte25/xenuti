# Copyright (C) 2014 Jan Rusnacko
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of the
# MIT license.

class Xenuti::Brakeman
  attr_accessor :config, :tracker

  # Check requirements for running this scanner - throws RuntimeError if any of
  # the requirements are not met. Returns true when requirements are met.
  def self.check_requirements(_config)
    # Verify brakeman is installed
    begin
      require 'brakeman' unless brakeman_loaded?
    rescue LoadError
      raise 'Could not load Brakeman'
    end

    true
  end

  # Return true iff Brakeman is already loaded
  def self.brakeman_loaded?
    begin
      Brakeman
    rescue NameError
      return false
    end
    true
  end

  def initialize(cfg)
    @config = cfg
    check_config
    process_config
  end

  def enabled?
    config.brakeman.enabled
  end

  def run_scan
    fail 'Brakeman is disabled' unless config.brakeman.enabled
    @tracker = Brakeman.run config.brakeman.options
  end

  def report
    tracker.report
  end

  def process_config
    # Set app_path for brakeman to the directory where we checked-out the code
    config.brakeman.options = { app_path: config.general.source }
  end

  def check_config
     # Verify that we have a path to app
    unless config.general.source.is_a? String
      fail 'Invalid source in config.general.source: #{config.general.source}.'
    end
    true
  end
end
