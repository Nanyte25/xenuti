# Copyright (C) 2014 Jan Rusnacko
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of the
# MIT license.

require 'xenuti/repository'

class Xenuti::Processor
  attr_accessor :config

  STATIC_ANALYZERS = [Xenuti::Brakeman]

  def initialize(config)
    @config = config
  end

  def run
    check_requirements
    checkout_code
    run_static_analysis
  end

  def check_requirements
    STATIC_ANALYZERS.each do |analyzer|
      analyzer.check_requirements(config)
    end
  end

  def checkout_code
    Xenuti::Repository.fetch_source(config, config.general.tmpdir + '/source')
  end

  def run_static_analysis
    STATIC_ANALYZERS.each do |klass|
      analyzer = klass.new(config)
      analyzer.run_scan if analyzer.enabled?
      puts analyzer.report
    end
  end
end
