# Copyright (C) 2014 Jan Rusnacko
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of the
# MIT license.

class Hash
  def symbolize_keys
    result = {}
    each_key do |key|
      result[key.to_sym] = self[key]
    end
    result
  end

  def symbolize_keys!
    keys.each do |key|
      self[key.to_sym] = delete(key)
    end
    self
  end

  def deep_symbolize_keys
    result = {}
    each_key do |key|
      if self[key].is_a? Hash
        result[key.to_sym] = self[key].deep_symbolize_keys
      else
        result[key.to_sym] = self[key]
      end
    end
    result
  end

  def deep_symbolize_keys!
    keys.each do |key|
      if self[key].is_a? Hash
        self[key.to_sym] = delete(key).deep_symbolize_keys
      else
        self[key.to_sym] = delete(key)
      end
    end
    self
  end

  def key_maxlen
    maxlen = 0
    each_key do |key|
      maxlen = key.size if key.size > maxlen
    end
    maxlen
  end
end
