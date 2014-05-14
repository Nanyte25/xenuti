# Copyright (C) 2014 Jan Rusnacko
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of the
# MIT license.

require 'rspec/expectations'

shared_examples 'hash with constraints' do |klass|
  let(:hashc) { klass.new(:a => 1, 'b' => { c: 2 }, 'd' => 3) }

  it 'check should return true when constraints are met' do
    hashc.constraints do |obj|
      expect(obj[:a]).to be_an(Integer)
      expect(obj[:d]).to be_eql(3)
    end
    expect(hashc.check).to be_true
  end

  it 'check should raise error when constraints are not met' do
    hashc.constraints do |obj|
      expect(obj[:a]).to be_an(Integer)
      expect(obj[:d]).to be_eql(:bogus)
    end
    expect do
      hashc.check
    end.to raise_error RuntimeError
  end
end
