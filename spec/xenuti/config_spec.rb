# Copyright (C) 2014 Jan Rusnacko
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of the
# MIT license.

require 'spec_helper'
# require 'ruby_util/hash_with_method_access_shared'

describe Xenuti::Config do
  let(:hash) do
    {
      general: { name: 'test' },
      process: { 'my_script' => { args: nil } },
      report: { send_mail: false }
    }
  end

  describe '::from_yaml' do
    it 'should deserialize YAML into config' do
      config = Xenuti::Config.from_yaml(File.new(CONFIG_FILEPATH).read)
      expect(config[:general][:name]).to be_eql('test')
    end

    it 'should have default values merged in' do
      config = Xenuti::Config.from_yaml(File.new(CONFIG_FILEPATH).read)
      expect(config[:general][:quiet]).to be_false
      expect(config[:general][:loglevel]).to be_eql('warn')
      expect(config[:content_update][:backend]).to be_eql('git')
      expect(config[:process][:my_script][:relative_path]).to be_eql([''])
    end
  end

  describe '::from_hash' do
    it 'should create config from hash with merged in default values' do
      config = Xenuti::Config.from_hash(hash)
      expect(config[:general][:name]).to be_eql('test')
      expect(config[:general][:workdir]).to be_nil
      expect(config[:general][:quiet]).to be_false
      expect(config[:content_update][:backend]).to be_eql('git')
      expect(config[:report][:send_mail]).to be_false
      expect(config[:process][:my_script][:diff]).to be_false
      expect(config[:process][:my_script][:relative_path]).to be_eql([''])
      expect(config[:process][:my_script][:diff_ignore]).to be_eql([])
    end
  end
end
