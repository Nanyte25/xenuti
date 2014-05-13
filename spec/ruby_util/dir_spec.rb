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
      Dir.new(FIXTURES_DIR).should be_eql(Dir.new(FIXTURES_DIR))
    end

    it 'should return false when comparing to different directory' do
      Dir.new(FIXTURES_DIR).should_not be_eql(Dir.new(FIXTURES_DIR + '/../'))
    end
  end

  context 'compare' do
    it 'should return true when comparing the same directories' do
      Dir.compare(FIXTURES_DIR, FIXTURES_DIR).should be_true
      Dir.compare(FIXTURES_DIR, Dir.new(FIXTURES_DIR)).should be_true
      Dir.compare(Dir.new(FIXTURES_DIR), FIXTURES_DIR).should be_true
    end

    it 'should return false when comparing different directories' do
      Dir.compare(FIXTURES_DIR, FIXTURES_DIR + '/../').should be_false
      Dir.compare(Dir.new(FIXTURES_DIR), FIXTURES_DIR + '/../').should be_false
      Dir.compare(FIXTURES_DIR, Dir.new(FIXTURES_DIR + '/../')).should be_false
    end

  end
end
