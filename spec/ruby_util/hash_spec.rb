# Copyright (C) 2014 Jan Rusnacko
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of the
# MIT license.

require 'spec_helper'
require 'ruby_util/hash'

describe Hash do
  it 'should symbolize_keys correctly' do
    expect({ 'a' => 1, 'b' => 2 }.symbolize_keys).to be_eql(a: 1, b: 2)
  end

  it 'should symbolize_keys! correctly' do
    h = { 'a' => 1, 'b' => 2 }.symbolize_keys!
    expect(h).to be_eql(a: 1, b: 2)
  end

  it 'should deep_symbolize_keys correctly' do
    expect({ 'a' => { 'b' => 2 } }.deep_symbolize_keys).to be_eql(a: { b: 2 })
  end

  it 'should deep_symbolize_keys! correctly' do
    h = { 'a' => { 'b' => 2 }, 'c' => 3 }.deep_symbolize_keys!
    expect(h).to be_eql(a: { b: 2 }, c: 3)
  end

  describe '#key_maxlen' do
    it 'should return maximum length of longest key' do
      warn = Xenuti::Warning.new(size: 1, longest: 2, short: 3)
      puts warn.key_maxlen
      expect(warn.key_maxlen).to be_eql(7)
    end

    it 'should return 0 for empty hash' do
      warn = Xenuti::Warning.new({})
      expect(warn.key_maxlen).to be_eql(0)
    end
  end
end
