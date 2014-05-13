# Copyright (C) 2014 Jan Rusnacko
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of the
# MIT license.

require 'spec_helper'
require 'ruby_util/hash'

describe Hash do
  it 'should symbolize_keys correctly' do
    { 'a' => 1, 'b' => 2 }.symbolize_keys.should be_eql(a: 1, b: 2)
  end

  it 'should symbolize_keys! correctly' do
    h = { 'a' => 1, 'b' => 2 }.symbolize_keys!
    h.should be_eql(a: 1, b: 2)
  end

  it 'should deep_symbolize_keys correctly' do
    { 'a' => { 'b' => 2 } }.deep_symbolize_keys.should be_eql(a: { b: 2 })
  end

  it 'should deep_symbolize_keys! correctly' do
    h = { 'a' => { 'b' => 2 } }.deep_symbolize_keys!
    h.should be_eql(a: { b: 2 })
  end
end
