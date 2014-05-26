# Copyright (C) 2014 Jan Rusnacko
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of the
# MIT license.

require 'spec_helper'
require 'ruby_util/hash_with_method_access_shared'

describe Xenuti::Warning do
  let(:warn) { Xenuti::Warning.from_hash(a: :b) }

  it_behaves_like 'hash with method access', Xenuti::Warning.new

  describe '::from_hash' do
    it 'should accept Hash as argument' do
      expect(warn.a).to be_eql(:b)
    end
  end

  # rubocop:disable UselessComparison
  describe '<=>' do
    it 'should throw error when not defined' do
      expect { warn <=> warn }.to raise_error NoMethodError
    end
  end
  # rubocop:enable UselessComparison
end
