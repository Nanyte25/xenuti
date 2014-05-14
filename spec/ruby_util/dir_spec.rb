# Copyright (C) 2014 Jan Rusnacko
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of the
# MIT license.

require 'spec_helper'
require 'ruby_util/dir'

describe Dir do
  context 'eql?' do
    it 'should return true when comparing to equal directory' do
      expect(Dir.new(FIXTURES)).to be_eql(Dir.new(FIXTURES))
    end

    it 'should return false when comparing to different directory' do
      expect(Dir.new(FIXTURES)).not_to be_eql(Dir.new(FIXTURES + '/../'))
    end
  end

  context 'compare' do
    it 'should return true when comparing the same directories' do
      expect(Dir.compare(FIXTURES, FIXTURES)).to be_true
      expect(Dir.compare(FIXTURES, Dir.new(FIXTURES))).to be_true
      expect(Dir.compare(Dir.new(FIXTURES), FIXTURES)).to be_true
    end

    it 'should return false when comparing different directories' do
      expect(Dir.compare(FIXTURES, FIXTURES + '/../')).to be_false
      expect(Dir.compare(Dir.new(FIXTURES), FIXTURES + '/../')).to be_false
      expect(Dir.compare(FIXTURES, Dir.new(FIXTURES + '/../'))).to be_false
    end
  end
end
