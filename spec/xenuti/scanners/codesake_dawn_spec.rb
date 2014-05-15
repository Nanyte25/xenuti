# Copyright (C) 2014 Jan Rusnacko
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of the
# MIT license.

require 'spec_helper'
require 'xenuti/scanners/static_analyzer_shared'

describe Xenuti::CodesakeDawn do
  let(:config) { Xenuti::Config.from_yaml(File.new(CONFIG_FILEPATH).read) }
  let(:codesake_dawn) { Xenuti::CodesakeDawn.new(config) }

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
  end
end
