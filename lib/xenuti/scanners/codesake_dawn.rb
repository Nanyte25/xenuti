# Copyright (C) 2014 Jan Rusnacko
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of the
# MIT license.

class Xenuti::CodesakeDawn
  include Xenuti::StaticAnalyzer
  attr_reader :output

  # Check requirements for running this scanner - throws RuntimeError if any of
  # the requirements are not met. Returns true when requirements are met.
  def self.check_requirements(_config)
    # This is much, much faster then %x(dawn -v)
    %x(whereis dawn | grep '/')
    fail 'CodesakeDawn not installed.' if $?.exitstatus != 0
    true
  end

  def initialize(cfg)
    super
  end

  def name
    'codesake_dawn'
  end

  def run_scan
    fail 'CodesakeDawn is disabled' unless config.codesake_dawn.enabled
    gemfile_lock_path = config.general.source + '/Gemfile.lock'
    fail 'Cannot find Gemfile.lock' unless File.exist?(gemfile_lock_path)

    @output = %x(dawn #{config.general.source})
  end

  def report
    output
  end
end
