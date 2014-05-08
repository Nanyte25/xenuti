# Copyright (C) 2014 Jan Rusnacko
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of the
# MIT license.

require 'spec_helper'

describe Xenuti::Config do
  let(:config_string) { File.new(FIXTURES_DIR + '/test_config.yml').read }
  let(:config) { Xenuti::Config.from_yaml(config_string) }

  it 'should allow read access through symbols' do
    c = Xenuti::Config.new({:a => 1, 'b' => 2})
    c[:a].should be_eql(1)
    c[:b].should be_eql(2)
  end

  it 'should allow read access through strings' do
    c = Xenuti::Config.new({:a => 1, 'b' => 2})
    c['a'].should be_eql(1)
    c['b'].should be_eql(2)
  end

  it 'should allow write access through symbols' do
    c = Xenuti::Config.new({:a => 1, 'b' => 2})
    c[:b] = 3
    c['b'].should be_eql(3)
  end

  it 'should allow write access through strings' do
    c = Xenuti::Config.new({:a => 1, 'b' => 2})
    c['a'] = 3
    c[:a].should be_eql(3)
  end

  it 'should convert all keys to symbols' do
    c = Xenuti::Config.new({"a" => 1, "b" => {"c" => 3}})
    c[:a].should be_eql(1)
    c[:b][:c].should be_eql(3)
  end

  it 'should allow access to entries by calling methods' do
    config.general.repo.should be_eql 'git@example.com:user/repo'
    config.brakeman.enabled.should be_true
    config.codesake_dawn.enabled.should be_false
  end

  it 'should allow changes in config via hash' do
    config[:codesake_dawn][:enabled] = true
    config[:codesake_dawn][:enabled].should be_true
  end

  it 'should allow changes in config via methods' do
    config.brakeman.enabled = false
    config.brakeman.enabled.should be_false
  end

  it 'should be hash-like' do
    expected = {
      :general => { :repo => 'git@example.com:user/repo' },
      :brakeman => {
        :enabled => true,
        :options => { :app_path => "/some/path" }
        },
      :codesake_dawn => { :enabled => false }
    }
    config.should be_eql(expected)
  end

  it 'should allow adding new configuration entries via methods' do
    config.unknown = :value
    config.unknown.should be_eql(:value)
    config[:unknown].should be_eql(:value)
  end

  it 'should allow adding hash as new entry' do
    config.unknown = {:key => :value}
    config.unknown[:key].should be_eql(:value)
  end
end
