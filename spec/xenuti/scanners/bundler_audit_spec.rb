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

  describe '#initialize' do
    it 'should load config file' do
      expect(bundler_audit.config.bundler_audit.enabled).to be_true
    end
  end

  describe '#name' do
    it 'should be bundler_audit' do
      expect(bundler_audit.name).to be_eql('bundler_audit')
    end
  end

  describe '#version' do
    it 'should return string with BundlerAudit version' do
      expect(bundler_audit.version).to match(/\A\d\.\d\.\d\Z/)
    end
  end

  describe '#run_scan' do
    it 'throws exception when called disabled' do
      config.bundler_audit.enabled = false
      expect { bundler_audit.run_scan }.to raise_error(RuntimeError)
    end
  end

  describe '#parse_bundler_audit_results' do
    let(:results) { [:a, :b, :c] }

    it 'should return Xenuti::Report' do
      expect(
        bundler_audit.parse_bundler_audit_results(results)
      ).to be_a(Xenuti::Report)
    end
  end
end
