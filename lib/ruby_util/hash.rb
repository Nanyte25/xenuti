# Copyright (C) 2014 Jan Rusnacko
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of the
# MIT license.

class Hash
  def stringify_keys
    result = {}
    each_key do |key|
      result[key.to_s] = self[key]
    end
    result
  end

  def stringify_keys!
    keys.each do |key|
      self[key.to_s] = delete(key)
    end
    self
  end

  def deep_stringify_keys
    result = {}
    each_key do |key|
      if self[key].is_a? Hash
        result[key.to_s] = self[key].deep_stringify_keys
      else
        result[key.to_s] = self[key]
      end
    end
    result
  end

  def deep_stringify_keys!
    keys.each do |key|
      if self[key].is_a? Hash
        self[key.to_s] = delete(key).deep_stringify_keys
      else
        self[key.to_s] = delete(key)
      end
    end
    self
  end

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

  def recursive_merge(other)
    result = clone
    other.each do |key, value|
      if result[key].is_a?(Hash) && value.is_a?(Hash)
        result[key].recursive_merge!(value)
      else
        result[key] = value
      end
    end
    result
  end

  def recursive_merge!(other)
    other.each do |key, value|
      if self[key].is_a?(Hash) && value.is_a?(Hash)
        self[key].recursive_merge!(value)
      else
        self[key] = value
      end
    end
    self
  end

  def soft_merge!(other)
    other.each do |key, value|
      if self[key].is_a?(Hash) && value.is_a?(Hash)
        self[key].soft_merge!(value)
      elsif self[key].nil?
        self[key] = value
      end
    end
    self
  end

  def soft_merge(other)
    result = clone
    other.each do |key, value|
      if result[key].is_a?(Hash) && value.is_a?(Hash)
        result[key].soft_merge!(value)
      elsif result[key].nil?
        result[key] = value
      end
    end
    result
  end
end
