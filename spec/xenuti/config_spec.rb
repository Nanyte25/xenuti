# Copyright (C) 2014 Jan Rusnacko
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of the
# MIT license.

require 'spec_helper'
require 'ruby_util/hash_with_method_access_shared'
require 'ruby_util/hash_with_constraints_shared'

describe Xenuti::Config do
  let(:config_string) { File.new(CONFIG_FILEPATH).read }
  let(:config) { Xenuti::Config.from_yaml(config_string) }

  it_behaves_like 'hash with method access', Xenuti::Config
  it_behaves_like 'hash with constraints', Xenuti::Config

  it 'should be hash-like' do
    expected = {
      general: { repo: 'git@example.com:user/repo', source: '/some/path' },
      brakeman: {
        enabled: true,
        options: { quiet: true }
        },
      codesake_dawn: { enabled: false },
      bundler_audit: { enabled: true }
    }
    expect(config).to be_eql(expected)
  end

  it 'constraints should work with method access' do
    expect do
      config.constraints do
        fail unless general.repo.is_a? String
        fail unless brakeman.enabled
        fail if codesake_dawn.enaled
      end
    end.to be_true
  end
end
