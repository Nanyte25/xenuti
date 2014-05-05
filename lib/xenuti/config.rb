# Copyright (C) 2014 Jan Rusnacko
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of the
# MIT license.

require 'safe_yaml'
require 'ruby_util/attribute_accessors'

class Xenuti::Config
  include AttributeAccessors

  def initialize(config_io)
    define_accessors(self, YAML.load(config_io.read, :safe => true))
  end

  def define_accessors(config, config_hash)
    config_hash.each_pair do |key, value|
      define_attr_reader(config, key)
      define_attr_writer(config, key)
      if value.is_a?(Hash)
        config.send("#{key}=", Object.new)
        define_accessors(config.send(key), value)
      else
        config.send("#{key}=", value)
      end
    end
  end
end
