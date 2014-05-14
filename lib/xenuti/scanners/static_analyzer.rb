# Copyright (C) 2014 Jan Rusnacko
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of the
# MIT license.

module Xenuti::StaticAnalyzer
  attr_accessor :config

  def initialize(cfg)
    @config = cfg
    self.class.check_requirements(@config)
    check_config
  end

  def enabled?
    config[name][:enabled]
  end

  def check_config
    # Verify that we have a path to app
    unless config.general.source.is_a? String
      fail 'Invalid source in config.general.source: #{config.general.source}.'
    end
    true
  end
end
