# Copyright (C) 2014 Jan Rusnacko
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of the
# MIT license.

require 'yaml'
require 'forwardable'
require 'ruby_util/hash'

class Xenuti::Config
  class ConfigWrapper
    def initialize(config_hash)
      @config_hash = config_hash.deep_symbolize_keys
    end

    def method_missing(name, *_args, &_block)
      case
      when @config_hash[name].is_a?(Hash)
        define_accessor name
        name = ConfigWrapper.new(@config_hash[name])
      when @config_hash[name]
        define_accessor name
        name = @config_hash[name]
      else
        fail(NoMethodError, "unknown configuration root #{name}", caller)
      end
    end

    def define_accessor(name)
      define_singleton_method "#{name}" do
        instance_variable_get("@#{name}")
      end

      define_singleton_method "#{name}=" do |value|
        instance_variable_set("@#{name}", value)
      end
    end
  end

  extend Forwardable
  def_delegator :@config_wrapper, :method_missing, :method_missing

  def initialize(config)
    @config_wrapper = ConfigWrapper.new(YAML.load(config.read))
  end
end
