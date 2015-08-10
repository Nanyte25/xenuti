  # Copyright (C) 2014 Jan Rusnacko
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of the
# MIT license.

require 'ruby_util/hash'

class Xenuti::Warning < Hash
  include Comparable

  def self.from_hash(hash)
    new.merge! hash
  end

  def <=>(_other)
    fail NoMethodError 'Every Warning must implement its own <=> method'
  end

  def formatted
    output = ''
    each do |key, value|
      output << format("%-#{key_maxlen}s: %s\n", key, value) unless value.nil?
    end
    output
  end

  def eql?(other)
    each_key do |key|
      return false unless key == :line || self[key].eql?(other[key])
    end
    true
  end

  def hash
    select { |k, _v| k != :line }.hash
  end
end
