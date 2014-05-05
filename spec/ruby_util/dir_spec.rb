# Copyright (C) 2014 Jan Rusnacko
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of the
# MIT license.

require 'spec_helper'
require 'ruby_util/dir'

describe Dir do
  it 'should correctly compare equal directories' do
    Dir.new(FIXTURES_DIR).should be_eql(Dir.new(FIXTURES_DIR))
  end

  it 'should correctly compare different directories' do
    Dir.new(FIXTURES_DIR).should_not be_eql(Dir.new(FIXTURES_DIR + "/../"))
  end
end