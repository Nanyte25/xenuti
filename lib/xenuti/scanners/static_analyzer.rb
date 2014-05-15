# Copyright (C) 2014 Jan Rusnacko
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of the
# MIT license.

require 'xenuti/report'

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
    config.verify do
      fail unless general.source.is_a? String
    end
    true
  end
end
