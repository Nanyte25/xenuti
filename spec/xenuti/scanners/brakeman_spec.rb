# Copyright (C) 2014 Jan Rusnacko
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of the
# MIT license.

require 'spec_helper'
require 'xenuti/scanners/scanner_shared'
require 'helpers/alpha_helper'

describe Xenuti::Brakeman do
  let(:config) do
    config = Xenuti::Config.from_yaml(File.new(CONFIG_FILEPATH).read)
    config
  end
  let(:alpha_config) { Xenuti::Config.from_yaml(File.new(ALPHA_CONFIG).read) }
  let(:brakeman_output) { File.new(BRAKEMAN_OUTPUT).read }
  let(:warning_hash) do
    {
      'warning_type'  => 'SQL Injection',
      'warning_code'  => 46,
      'message'       => 'Application contains SQL injection.',
      'file'          => 'foo',
      'confidence'    => 'High'
    }
  end
  let(:warning) { Xenuti::Brakeman::Warning.from_hash(warning_hash) }

  it_behaves_like 'scanner', Xenuti::Brakeman

  describe 'Warning' do
    describe '::from_hash' do
      it 'should accept hash with correct fields' do
        expect(warning).to be_a(Xenuti::Brakeman::Warning)
      end
    end

    # rubocop:disable UselessComparison
    describe '<=>' do
      it 'should compare warnings by confidence' do
        high = warning.clone
        medium = warning.clone
        weak = warning.clone

        high['confidence'] = 'High'
        weak['confidence'] = 'Weak'
        medium['confidence'] = 'Medium'

        expect(high <=> weak).to be_eql(-1)
        expect(high <=> medium).to be_eql(-1)
        expect(medium <=> weak).to be_eql(-1)

        expect(weak <=> medium).to be_eql(1)
        expect(medium <=> high).to be_eql(1)
        expect(weak <=> high).to be_eql(1)

        expect(weak <=> weak).to be_eql(0)
        expect(medium <=> medium).to be_eql(0)
        expect(high <=> high).to be_eql(0)
      end
    end
    # rubocop:enable UselessComparison
  end

  describe '::name' do
    it 'should be brakeman' do
      expect(Xenuti::Brakeman.name).to be_eql('brakeman')
    end
  end

  describe '::version' do
    it 'should return string with Brakeman version' do
      expect(Xenuti::Brakeman.version).to match(/\A\d\.\d\.\d\Z/)
    end
  end

  describe '::check_config' do
    it 'should fail if source is not present in config' do
      config.general.source = nil
      expect do
        Xenuti::Brakeman.check_config(config)
      end.to raise_error TypeError
      config.general = nil
      expect do
        Xenuti::Brakeman.check_config(config)
      end.to raise_error NoMethodError
    end

    it 'should pass when source is present in config' do
      alpha_config.general.source = ALPHA_REPO
      expect(Xenuti::Brakeman.check_config(alpha_config)).to be_true
    end
  end

  describe '::execute_scan' do
    it 'throws exception when called disabled' do
      config.brakeman.enabled = false
      expect do
        Xenuti::Brakeman.execute_scan(config, '/some/path')
      end.to raise_error(RuntimeError)
    end

    it 'runs scan and returns Brakeman output in JSON' do
      # By default alpha_config has all scanners disabled.
      alpha_config.brakeman.enabled = true

      output = Xenuti::Brakeman.execute_scan(alpha_config, ALPHA_REPO)
      parsed = JSON.load(output)
      expect(parsed['scan_info']['app_path']).to be_eql(ALPHA_REPO)
    end
  end

  describe '::parse_results' do
    it 'should parse brakeman output into ScannerReport correctly' do
      report = Xenuti::Brakeman.parse_results(brakeman_output)
      expect(report).to be_a(Xenuti::ScannerReport)
      expect(report.warnings[1]).to be_a(Xenuti::Brakeman::Warning)
      expect(report.warnings[1][:warning_code]).to be >= 73
    end
  end
end
