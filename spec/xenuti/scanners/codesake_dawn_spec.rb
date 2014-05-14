# Copyright (C) 2014 Jan Rusnacko
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of the
# MIT license.

require 'spec_helper'
require 'xenuti/scanners/static_analyzer_helper'

describe Xenuti::CodesakeDawn do
  let(:config) { Xenuti::Config.from_yaml(File.new(CONFIG_FILEPATH).read) }
  let(:codesake_dawn) { Xenuti::CodesakeDawn.new(config) }

  it_behaves_like 'static_analyzer', Xenuti::Brakeman

  it 'should load config file' do
    expect(config.codesake_dawn.enabled).to be_false
  end

  context 'run_scan' do
    it 'throws exception when called disabled' do
      config.codesake_dawn.enabled = false
      expect { codesake_dawn.run_scan }.to raise_error(RuntimeError)
    end
  end
end
