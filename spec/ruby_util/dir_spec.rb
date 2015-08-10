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
      expect(Dir.compare(FIXTURES, FIXTURES)).to be true
      expect(Dir.compare(FIXTURES, Dir.new(FIXTURES))).to be true
      expect(Dir.compare(Dir.new(FIXTURES), FIXTURES)).to be true
    end

    it 'should return false when comparing different directories' do
      expect(Dir.compare(FIXTURES, FIXTURES + '/../')).to be false
      expect(Dir.compare(Dir.new(FIXTURES), FIXTURES + '/../')).to be false
      expect(Dir.compare(FIXTURES, Dir.new(FIXTURES + '/../'))).to be false
    end
  end

  context 'jumpd' do
    it 'should execute block in new directory' do
      Dir.jumpd('/tmp') do
        expect(Dir.pwd).to be_eql('/tmp')
      end
    end

    it 'should change back to old directory after block is executed' do
      old_pwd = Dir.pwd
      Dir.jumpd('/tmp') {}
      expect(Dir.pwd).to be_eql(old_pwd)
    end

    it 'should let error propagate from block, but change back to old dir' do
      old_pwd = Dir.pwd
      expect do
        Dir.jumpd('/tmp') { fail 'Nope!' if Dir.pwd == '/tmp' }
      end.to raise_error RuntimeError
      expect(Dir.pwd).to be_eql(old_pwd)
    end
  end
end
