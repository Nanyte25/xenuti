# Copyright (C) 2014 Jan Rusnacko
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of the
# MIT license.

require 'spec_helper'

describe Xenuti::Brakeman do
  let(:config) { Xenuti::Config.from_yaml(File.new(CONFIG_FILEPATH).read) }
  let(:brakeman) { Xenuti::Brakeman.new(config) }

  it 'should load config file' do
    config.brakeman.options.quiet.should be_true
  end

  context 'run_scan' do
    it 'throws exception when called disabled' do
      config.brakeman.enabled = false
      expect { brakeman.run_scan }.to raise_error(RuntimeError)
    end
  end

  context 'check_config' do
    it 'should fail if source is not present in config' do
      config.general.source = nil
      expect do
        brakeman.check_config
      end.to raise_error RuntimeError
      config.general = nil
      expect do
        brakeman.check_config
      end.to raise_error NoMethodError
    end

    it 'should pass when app_path is present and brakeman is installed' do
      brakeman.check_config.should be_true
    end
  end

  context 'enabled?' do
    it 'can be enabled' do
      config.brakeman.enabled = true
      brakeman.enabled?.should be_true
    end

    it 'can be disabled' do
      config.brakeman.enabled = false
      brakeman.enabled?.should be_false
    end
  end
end
