# Copyright (C) 2014 Jan Rusnacko
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of the
# MIT license.

require 'spec_helper'

describe Xenuti::Config do
  let(:config_file) { FIXTURES_DIR + '/test_config.yml' }

  context 'parsing' do
    it 'should parse config correctly' do
      config = Xenuti::Config.new(File.new config_file)
      config.general.repo.should be_eql 'git@example.com:user/repo'
      config.static_analysis.brakeman.enabled.should be_true
      config.static_analysis.codesake_dawn.enabled.should be_false
    end
  end
end
