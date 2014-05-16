# Copyright (C) 2014 Jan Rusnacko
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of the
# MIT license.

require 'spec_helper'
require 'ruby_util/hash_with_method_access_shared'

describe 'warning' do
  it_behaves_like 'hash with method access', Xenuti::Warning

  describe '#initialize' do
    it 'should accept Hash as argument' do
      warn = Xenuti::Warning.new(a: :b)
      expect(warn.a).to be_eql(:b)
    end
  end
end
