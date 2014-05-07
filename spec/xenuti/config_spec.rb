# Copyright (C) 2014 Jan Rusnacko
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of the
# MIT license.

require 'spec_helper'

describe Xenuti::Config do
  let(:config_file) { FIXTURES_DIR + '/test_config.yml' }

  it 'should parse config correctly' do
    config = Xenuti::Config.new(File.new config_file)
    config.general.repo.should be_eql 'git@example.com:user/repo'
    config.static_analysis.brakeman.enabled.should be_true
    config.static_analysis.codesake_dawn.enabled.should be_false
  end

  it 'should allow changes in config' do
    config = Xenuti::Config.new(File.new config_file)
    config.static_analysis.brakeman.enabled = false
    config.static_analysis.brakeman.enabled.should be_false
  end

  it 'should allow conversion of config back to hash' do
    expected = {
      :general => { :repo => 'git@example.com:user/repo' },
      :static_analysis => {
        :brakeman => { :enabled => true },
        :codesake_dawn => { :enabled => false}
      }
    }
    config.to_hash.should be_eql(expected)
  end

  it 'should allow conversion of subtrees back to hash' do
    expected = { :enabled => true }
    config.static_analysis.brakeman.to_hash.should be_eql(expected)
  end

  it 'converted hash should contain changed values' do
    expected = { :enabled => false }
    config.static_analysis.brakeman.enabled = false
    config.static_analysis.brakeman.to_hash.should be_eql(expected)
  end

  it 'should allow soft merge to set default values' do
    expected = { :enabled => true, :default => :value }
    default = { :enable => false, :default => :value }
    config.static_analysis.brakeman.soft_merge(default)
    config.static_analysis.brakeman.enabled.should be_true
    config.static_analysis.brakeman.default.should be_eql(:value)
  end

  it 'should allow adding new configuration entries' do
    config.unknown.entry = :value
    config.unknown.entry.should be_eql(:value)
  end

  it 'converted hash should contain new config entries' do
    config.unknown.entry = :value
    config.unknown.to_hash.should be_eql({:entry => :value})
  end
end
