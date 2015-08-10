# Copyright (C) 2014 Jan Rusnacko
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of the
# MIT license.

require 'rspec/expectations'

describe 'hash with constraints' do
  let(:hashc) do
    { :a => 1, 'b' => { c: 2 }, 'd' => 3 }.extend(HashWithConstraints)
  end

  context 'check' do
    it 'should return true when constraints are met' do
      hashc.constraints do
        fail unless self[:a].is_a? Integer
        fail unless self['d'].eql? 3
      end
      expect(hashc.check).to be true
    end

    it 'should raise error when constraints are not met' do
      hashc.constraints do
        fail unless self[:a].is_a? Integer
        fail unless self['d'].eql? 4
      end
      expect { hashc.check }.to raise_error RuntimeError
    end
  end

  context 'constraints' do
    it 'should accept multiple constraints and pass when all are met' do
      hashc.constraints do
        fail unless self[:a].is_a? Integer
      end
      hashc.constraints do
        fail unless self['d'].eql? 3
      end
      expect(hashc.check).to be true
    end

    it 'should accept multiple constraints and fail if any is not met' do
      hashc.constraints do
        fail unless self[:a].is_a? Integer
      end
      hashc.constraints do
        fail unless self['d'].eql? 4
      end
      expect { hashc.check }.to raise_error RuntimeError
    end
  end

  context 'verify' do
    it 'should return true when constraints passed are met' do
      expect(
        hashc.verify do
          fail unless self[:a].is_a? Integer
          fail unless self['d'].eql? 3
        end
      ).to be true
    end

    it 'should raise error when constraints passed are not met' do
      expect do
        hashc.verify do
          fail unless self[:a].is_a? Integer
          fail unless self['d'].eql? 4
        end
      end.to raise_error RuntimeError
    end
  end
end
