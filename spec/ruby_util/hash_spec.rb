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
      hash = { size: 1, longest: 2, short: 3 }
      expect(hash.key_maxlen).to be_eql(7)
    end

    it 'should return 0 for empty hash' do
      hash = {}
      expect(hash.key_maxlen).to be_eql(0)
    end
  end

  describe '#recursive_merge' do
    it 'should return new hash' do
      hash1 = { a: 1, b: 2 }
      hash2 = { a: 2, c: 3 }
      expect(hash1.recursive_merge(hash2)).to be_eql(a: 2, b: 2, c: 3)
      expect(hash1).to be_eql(a: 1, b: 2)
      expect(hash2).to be_eql(a: 2, c: 3)
    end

    it 'should merge correctly' do
      hash1 = { a: 1, b: { c: 2, d: 3 }, e: { f: 4 } }
      hash2 = { b: { c: 5 }, e: 6 }
      result = hash1.recursive_merge(hash2)
      expect(result).to be_eql(a: 1, b: { c: 5, d: 3 }, e: 6)
    end
  end

  describe '#recursive_merge!' do
    it 'should merge correctly' do
      hash1 = { a: 1, b: { c: 2, d: 3 }, e: { f: 4 } }
      hash2 = { b: { c: 5 }, e: 6 }
      hash1.recursive_merge!(hash2)
      expect(hash1).to be_eql(a: 1, b: { c: 5, d: 3 }, e: 6)
    end
  end
end
