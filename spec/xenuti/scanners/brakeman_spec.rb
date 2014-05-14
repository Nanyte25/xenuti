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

  it 'should load config file' do
    expect(config.brakeman.options.quiet).to be_true
  end

  context 'run_scan' do
    it 'throws exception when called disabled' do
      config.brakeman.enabled = false
      expect { brakeman.run_scan }.to raise_error(RuntimeError)
    end
  end

  context 'process_config' do
    it 'should set up app_path for brakeman from source' do
      config.general.source = '/some/path'
      brakeman.process_config
      expect(config.brakeman.options.app_path).to be_eql('/some/path')
    end
  end
end
