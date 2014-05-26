# Copyright (C) 2014 Jan Rusnacko
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of the
# MIT license.

shared_examples 'hash with method access' do |hash|
  let(:hashw) do
    hash[:a] = 1
    hash['b'] = { c: 2 }
    hash['d'] = 3
    hash
  end

  it 'should allow read access through symbols' do
    expect(hashw[:a]).to be_eql(1)
    expect(hashw[:d]).to be_eql(3)
  end

  it 'should allow read access through strings' do
    expect(hashw['a']).to be_eql(1)
    expect(hashw['d']).to be_eql(3)
  end

  it 'should allow write access through symbols' do
    hashw[:d] = 4
    expect(hashw['d']).to be_eql(4)
  end

  it 'should allow write access through strings' do
    hashw['a'] = 4
    expect(hashw[:a]).to be_eql(4)
  end

  it 'should convert all keys to symbols' do
    expect(hashw[:a]).to be_eql(1)
    expect(hashw[:b][:c]).to be_eql(2)
    expect(hashw[:d]).to be_eql(3)
  end

  it 'should allow access to entries by calling methods' do
    expect(hashw.a).to be_eql(1)
    expect(hashw.b).to be_eql(c: 2)
    expect(hashw.b.c).to be_eql(2)
    expect(hashw.d).to be_eql(3)
  end

  it 'should allow changes in hashw via hash' do
    hashw[:b][:c] = true
    expect(hashw.b.c).to be_true
  end

  it 'should allow changes in hashw via methods' do
    hashw.b.c = false
    expect(hashw[:b][:c]).to be_false
  end

  it 'should allow adding new entries via methods' do
    hashw.unknown = :value
    expect(hashw[:unknown]).to be_eql(:value)
    expect(hashw.unknown).to be_eql(:value)
  end

  it 'should allow adding hash as new entry' do
    hashw.unknown = { foo: :bar }
    expect(hashw.unknown[:foo]).to be_eql(:bar)
    expect(hashw.unknown.foo).to be_eql(:bar)
  end

  it 'should throw NoMethodError when unspecified root is called' do
    expect { hashw.unknown.conf.root }.to raise_error NoMethodError
  end

  it 'merge! with ordinary hash and keep method access' do
    hashw.merge!('e' => 4, :f => 5)
    expect(hashw.e).to be_eql(4)
    expect(hashw.f).to be_eql(5)
  end

  it 'merge with ordinary hash and keep method access' do
    hash = hashw.merge('e' => 4, :f => 5)
    expect(hash.e).to be_eql(4)
    expect(hash.f).to be_eql(5)
  end
end
