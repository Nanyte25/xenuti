# Copyright (C) 2014 Jan Rusnacko
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of the
# MIT license.

require 'spec_helper'
require 'xenuti/scanners/static_analyzer_shared'

describe Xenuti::BundlerAudit do
  let(:config) { Xenuti::Config.from_yaml(File.new(CONFIG_FILEPATH).read) }
  let(:bundler_audit) { Xenuti::BundlerAudit.new(config) }

  it_behaves_like 'static_analyzer', Xenuti::BundlerAudit

  it 'should load config file' do
    expect(config.bundler_audit.enabled).to be_true
  end

  context 'run_scan' do
    it 'throws exception when called disabled' do
      config.bundler_audit.enabled = false
      expect { bundler_audit.run_scan }.to raise_error(RuntimeError)
    end
  end
end
