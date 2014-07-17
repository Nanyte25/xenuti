# Copyright (C) 2014 Jan Rusnacko
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of the
# MIT license.

require 'spec_helper'
require 'xenuti/scanners/scanner_shared'

describe Xenuti::BundlerAudit do
  let(:config) do
    config = Xenuti::Config.from_yaml(File.new(CONFIG_FILEPATH).read)
    config.general.app_dir = ALPHA_REPO
    config
  end
  let(:alpha_config) { Xenuti::Config.from_yaml(File.new(ALPHA_CONFIG).read) }
  let(:bundler_audit_output) { File.new(BUNDLER_AUDIT_OUTPUT).read }
  let(:warning_hash) do
    {
      name:         'actionmailer',
      version:      '3.2.9',
      advisory:     'OSVDB-98629',
      criticality:  'Medium',
      url:          'http://www.osvdb.org/show/osvdb/98629',
      title:        'Action Mailer Gem contains a possible DoS Vulnerability',
      solution:     'upgrade to >= 3.2.15'
    }
  end
  let(:warning) { Xenuti::BundlerAudit::Warning.from_hash(warning_hash) }

  it_behaves_like 'scanner', Xenuti::BundlerAudit

  describe 'Warning' do
    describe '::from_hash' do
      it 'should accept hash with correct fields' do
        expect(warning).to be_a(Xenuti::BundlerAudit::Warning)
      end
    end

    # rubocop:disable UselessComparison
    describe '<=>' do
      it 'should compare warnings by criticality' do
        high = warning.clone
        medium = warning.clone
        low = warning.clone
        unknown = warning.clone

        high['criticality'] = 'High'
        medium['criticality'] = 'Medium'
        low['criticality'] = 'Low'
        unknown['criticality'] = 'Unknown'

        expect(high <=> low).to be_eql(-1)
        expect(high <=> medium).to be_eql(-1)
        expect(medium <=> low).to be_eql(-1)
        expect(low <=> unknown).to be_eql(-1)

        expect(unknown <=> low).to be_eql(1)
        expect(low <=> medium).to be_eql(1)
        expect(medium <=> high).to be_eql(1)
        expect(unknown <=> high).to be_eql(1)

        expect(unknown <=> unknown).to be_eql(0)
        expect(low <=> low).to be_eql(0)
        expect(medium <=> medium).to be_eql(0)
        expect(high <=> high).to be_eql(0)
      end
    end
    # rubocop:enable UselessComparison
  end

  describe '::name' do
    it 'should be bundler_audit' do
      expect(Xenuti::BundlerAudit.name).to be_eql('bundler_audit')
    end
  end

  describe '::version' do
    it 'should return string with BundlerAudit version' do
      expect(Xenuti::BundlerAudit.version).to match(/\A\d\.\d\.\d\Z/)
    end
  end

  describe '::check_config' do
    it 'should fail if app_dir is not present in config' do
      config.general.app_dir = nil
      expect do
        Xenuti::BundlerAudit.check_config(config)
      end.to raise_error TypeError
      config.general = nil
      expect do
        Xenuti::BundlerAudit.check_config(config)
      end.to raise_error NoMethodError
    end

    it 'should pass when source is present in config' do
      expect(Xenuti::BundlerAudit.check_config(config)).to be_true
    end
  end

  describe '::execute_scan' do
    it 'throws exception when called disabled' do
      config.bundler_audit.enabled = false
      expect do
        Xenuti::BundlerAudit.execute_scan(config)
      end.to raise_error(RuntimeError)
    end

    it 'runs scan and captures BundlerAudit output' do
      # Small hack - I don`t want to clone the repo to get source, so just
      # hardcode it like this
      alpha_config.general.app_dir = alpha_config.general.repo

      # By default alpha_config has all scanners disabled.
      alpha_config.bundler_audit.enabled = true

      output = Xenuti::BundlerAudit.execute_scan(alpha_config)
      # At this moment there are 16 vulnerabilities, might be more in future
      expect(output.scan(/Name:.*?Solution:.*?\n/m).size).to be >= 16
    end
  end

  describe '::parse_results' do
    it 'should parse bunler audit output into :ReScannerReportport correctly' do
      report = Xenuti::BundlerAudit.parse_results(bundler_audit_output)
      expect(report).to be_a(Xenuti::ScannerReport)
      expect(report.warnings[1]).to be_a(Xenuti::BundlerAudit::Warning)
      expect(report.warnings[1].advisory).to be_eql('OSVDB-100527')
    end
  end
end
