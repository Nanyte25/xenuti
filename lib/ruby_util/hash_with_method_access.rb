# Copyright (C) 2014 Jan Rusnacko
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of the
# MIT license.

module HashWithMethodAccess
  def [](key)
    key = key.to_sym if key.is_a? String
    super(key)
  end

  def []=(key, val)
    key = key.to_sym if key.is_a? String
    # val = self.class.new(val) if val.is_a? Hash
    val.extend(HashWithMethodAccess) if val.is_a? Hash
    super(key, val)
  end

  def merge(other)
    super(other.deep_symbolize_keys)
  end

  def merge!(other)
    super(other.deep_symbolize_keys)
  end

  # rubocop:disable NonNilCheck
  def method_missing(name, *args, &block)
    if name =~ /=\Z/
      define_accessor name
      send(name, *args, &block)
    elsif !self[name].nil?
      define_accessor name
      self[name].extend(HashWithMethodAccess) if self[name].is_a?(Hash)
      send(name, *args, &block)
    else
      fail(NoMethodError, "unknown configuration root #{name}", caller)
    end
  end
  # rubocop:enable NonNilCheck

  def define_accessor(name)
    name = name.to_s.sub('=', '')

    define_singleton_method name do
      self[name]
    end

    define_singleton_method "#{name}=" do |val|
      self[name] = val
    end
  end
end
