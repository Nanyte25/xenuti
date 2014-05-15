# Copyright (C) 2014 Jan Rusnacko
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of the
# MIT license.

require 'spec_helper'
require 'xenuti/scanners/static_analyzer_shared'

describe Xenuti::Brakeman do
  let(:config) { Xenuti::Config.from_yaml(File.new(CONFIG_FILEPATH).read) }
  let(:brakeman) { Xenuti::Brakeman.new(config) }

  it_behaves_like 'static_analyzer', Xenuti::Brakeman

  describe '#initialize' do
    it 'should load config file' do
      expect(brakeman.config.brakeman.options.quiet).to be_true
    end
  end

  describe '#name' do
    it 'should be brakeman' do
      expect(brakeman.name).to be_eql('brakeman')
    end
  end

  describe '#version' do
    it 'should return string with Brakeman version' do
      expect(brakeman.version).to match(/\A\d\.\d\.\d\Z/)
    end
  end

  describe '#run_scan' do
    it 'throws exception when called disabled' do
      config.brakeman.enabled = false
      expect { brakeman.run_scan }.to raise_error(RuntimeError)
    end
  end

  describe '#process_config' do
    it 'should set up app_path for brakeman from source' do
      config.general.source = '/some/path'
      brakeman.process_config
      expect(config.brakeman.options.app_path).to be_eql('/some/path')
    end
  end
end
