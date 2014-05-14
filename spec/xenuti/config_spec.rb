# Copyright (C) 2014 Jan Rusnacko
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of the
# MIT license.

require 'spec_helper'

describe Xenuti::Config do
  let(:config_string) { File.new(CONFIG_FILEPATH).read }
  let(:config) { Xenuti::Config.from_yaml(config_string) }

  it 'should allow read access through symbols' do
    c = Xenuti::Config.new(:a => 1, 'b' => 2)
    expect(c[:a]).to be_eql(1)
    expect(c[:b]).to be_eql(2)
  end

  it 'should allow read access through strings' do
    c = Xenuti::Config.new(:a => 1, 'b' => 2)
    expect(c['a']).to be_eql(1)
    expect(c['b']).to be_eql(2)
  end

  it 'should allow write access through symbols' do
    c = Xenuti::Config.new(:a => 1, 'b' => 2)
    c[:b] = 3
    expect(c['b']).to be_eql(3)
  end

  it 'should allow write access through strings' do
    c = Xenuti::Config.new(:a => 1, 'b' => 2)
    c['a'] = 3
    expect(c[:a]).to be_eql(3)
  end

  it 'should convert all keys to symbols' do
    c = Xenuti::Config.new('a' => 1, 'b' => { 'c' => 3 })
    expect(c[:a]).to be_eql(1)
    expect(c[:b][:c]).to be_eql(3)
  end

  it 'should allow access to entries by calling methods' do
    expect(config.general.repo).to be_eql 'git@example.com:user/repo'
    expect(config.brakeman.enabled).to be_true
    expect(config.codesake_dawn.enabled).to be_false
  end

  it 'should allow changes in config via hash' do
    config[:codesake_dawn][:enabled] = true
    expect(config[:codesake_dawn][:enabled]).to be_true
  end

  it 'should allow changes in config via methods' do
    config.brakeman.enabled = false
    expect(config.brakeman.enabled).to be_false
  end

  it 'should be hash-like' do
    expected = {
      general: { repo: 'git@example.com:user/repo', source: '/some/path' },
      brakeman: {
        enabled: true,
        options: { quiet: true }
        },
      codesake_dawn: { enabled: false }
    }
    expect(config).to be_eql(expected)
  end

  it 'should allow adding new configuration entries via methods' do
    config.unknown = :value
    expect(config.unknown).to be_eql(:value)
    expect(config[:unknown]).to be_eql(:value)
  end

  it 'should allow adding hash as new entry' do
    config.unknown = { key: :value }
    expect(config.unknown[:key]).to be_eql(:value)
  end
end
