# Copyright (C) 2014 Jan Rusnacko
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of the
# MIT license.

require 'spec_helper'
require 'xenuti/scanners/static_analyzer_shared'
require 'helpers/alpha_helper'

describe Xenuti::CodesakeDawn do
  let(:config) { Xenuti::Config.from_yaml(File.new(CONFIG_FILEPATH).read) }
  let(:alpha_config) { Xenuti::Config.from_yaml(File.new(ALPHA_CONFIG).read) }
  let(:codesake_dawn) { Xenuti::CodesakeDawn.new(config) }
  let(:alpha_codesake_dawn) { Xenuti::CodesakeDawn.new(alpha_config) }
  let(:codesake_dawn_output) { File.new(CODESAKE_DAWN_OUTPUT).read }

  it_behaves_like 'static_analyzer', Xenuti::CodesakeDawn

  describe '#initialize' do
    it 'should load config file' do
      expect(codesake_dawn.config.codesake_dawn.enabled).to be_false
    end
  end

  describe '#name' do
    it 'should be codesake_dawn' do
      expect(codesake_dawn.name).to be_eql('codesake_dawn')
    end
  end

  describe '#version' do
    it 'should return string with CodesakeDawn version' do
      # TODO: enable test again
      # This test takes about 1 second, as invoking dawn is terribly slow,
      # so commenting this out.

      # expect(codesake_dawn.version).to match(/\A\d\.\d\.\d\Z/)
    end
  end

  context '#run_scan' do
    it 'throws exception when called disabled' do
      config.codesake_dawn.enabled = false
      expect { codesake_dawn.run_scan }.to raise_error(RuntimeError)
    end

    it 'runs scan and captures CodesakeDawn output' do
      # Small hack - I don`t want to clone the repo to get source, so just
      # hardcode it like this
      alpha_config.general.source = alpha_config.general.repo

      # By default alpha_config has all scanners disabled.
      alpha_config.codesake_dawn.enabled = true

      expect(alpha_codesake_dawn.instance_variable_get('@results')).to be_nil
      alpha_codesake_dawn.run_scan
      expect(
        alpha_codesake_dawn.instance_variable_get('@results')
      ).to be_a(String)
    end
  end

  describe '#parse_results' do
    it 'should parse codesake_dawn output into Xenuti::Report correctly' do
      report = codesake_dawn.parse_results(codesake_dawn_output)
      expect(report).to be_a(Xenuti::Report)
      expect(report.warnings[0]['name']).to be_eql('CVE-2012-6496')
    end
  end
end
