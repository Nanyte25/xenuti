# Copyright (C) 2014 Jan Rusnacko
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of the
# MIT license.

require 'spec_helper'
require 'ruby_util/hash_with_method_access_shared'

describe Xenuti::Config do
  let(:hash) do
    {
      general: { repo: 'git@example.com:user/repo' },
      brakeman: { enabled: false }
    }
  end

  it_behaves_like 'hash with method access', Xenuti::Config.new

  describe '#initialize' do
    it 'should get default values merged in' do
      expect(Xenuti::Config.new).to be_eql \
        Xenuti::Config::DEFAULT_CONFIG.deep_symbolize_keys
    end
  end

  describe '::from_yaml' do
    it 'should deserialize YAML into config' do
      config = Xenuti::Config.from_yaml(File.new(CONFIG_FILEPATH).read)
      expect(config.general.repo).to be_eql('git@example.com:user/repo')
    end

    it 'should have default values merged in' do
      config = Xenuti::Config.from_yaml(File.new(CONFIG_FILEPATH).read)
      expect(config.smtp.enabled).to be_false
      expect(config.general.quiet).to be_false
      expect(config.general.relative_path).to be_eql([''])
    end
  end

  describe '::from_hash' do
    it 'should create config from hash with merged in default values' do
      config = Xenuti::Config.from_hash(hash)
      expect(config[:general][:repo]).to be_eql('git@example.com:user/repo')
      expect(config[:general][:workdir]).to be_nil
      expect(config.general.quiet).to be_false
      expect(config.general.relative_path).to be_eql([''])
      expect(config.smtp.enabled).to be_false
      expect(config[:brakeman][:enabled]).to be_false
      expect(config[:bundler_audit][:enabled]).to be_true
    end
  end

  it 'constraints should work with method access' do
    config = Xenuti::Config.from_hash(hash)
    expect(
      config.verify do
        fail unless general.repo.is_a? String
        fail if brakeman.enabled
        fail unless codesake_dawn.enabled
      end
    ).to be_true
  end
end
