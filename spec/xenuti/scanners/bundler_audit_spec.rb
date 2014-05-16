# Copyright (C) 2014 Jan Rusnacko
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of the
# MIT license.

require 'spec_helper'
require 'xenuti/scanners/static_analyzer_shared'

describe Xenuti::BundlerAudit do
  let(:config) { Xenuti::Config.from_yaml(File.new(CONFIG_FILEPATH).read) }
  let(:alpha_config) { Xenuti::Config.from_yaml(File.new(ALPHA_CONFIG).read) }
  let(:bundler_audit) { Xenuti::BundlerAudit.new(config) }
  let(:alpha_bundler_audit) { Xenuti::BundlerAudit.new(alpha_config) }
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
  let(:warning) { Xenuti::BundlerAudit::Warning.new(warning_hash) }

  it_behaves_like 'static_analyzer', Xenuti::BundlerAudit

  describe 'Warning' do
    describe '#initialize' do
      it 'should accept hash with correct fields' do
        expect(warning.check).to be_true
      end
    end

    describe '#check' do
      it 'should require name to be a String' do
        warning.name = :SQL
        expect { warning.check }.to raise_error RuntimeError
      end

      it 'should require version to be a String' do
        warning.version = 1
        expect { warning.check }.to raise_error RuntimeError
      end

      it 'should require advisory to be a String' do
        warning.advisory = Time.now
        expect { warning.check }.to raise_error RuntimeError
      end

      it 'should require url to be a String' do
        warning.url = 1
        expect { warning.check }.to raise_error RuntimeError
      end

      it 'should require title to be a String' do
        warning.title = 1
        expect { warning.check }.to raise_error RuntimeError
      end

      it 'should require solution to be a String' do
        warning.solution = 1
        expect { warning.check }.to raise_error RuntimeError
      end

      it 'should verify criticality is one of High, Medium, Low, Unknown' do
        warning.criticality = 'High'
        expect(warning.check).to be_true
        warning.criticality = 'Medium'
        expect(warning.check).to be_true
        warning.criticality = 'Low'
        expect(warning.check).to be_true
        warning.criticality = 'Unknown'
        expect(warning.check).to be_true

        warning.criticality = 'Higher'
        expect { warning.check }.to raise_error RuntimeError
      end
    end
  end

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

    it 'runs scan and captures BundlerAudit output' do
      # Small hack - I don`t want to clone the repo to get source, so just
      # hardcode it like this
      alpha_config.general.source = alpha_config.general.repo

      # By default alpha_config has all scanners disabled.
      alpha_config.bundler_audit.enabled = true

      expect(alpha_bundler_audit.instance_variable_get('@results')).to be_nil
      alpha_bundler_audit.run_scan
      expect(
        alpha_bundler_audit.instance_variable_get('@results')
      ).to be_a(String)
    end
  end

  describe '#parse_results' do
    it 'should parse bunler audit output into Xenuti::Report correctly' do
      report = bundler_audit.parse_results(bundler_audit_output)
      expect(report).to be_a(Xenuti::Report)
      expect(report.warnings[0]).to be_a(Xenuti::Warning)
      expect(report.warnings[0].advisory).to be_eql('OSVDB-98629')
    end
  end
end
