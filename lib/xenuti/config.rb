# Copyright (C) 2014 Jan Rusnacko
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of the
# MIT license.

require 'safe_yaml'
require 'ruby_util/hash'
require 'ruby_util/hash_with_method_access'
require 'ruby_util/hash_with_constraints'

class Xenuti::Config < Hash
  include HashWithMethodAccess
  include HashWithConstraints

  DEFAULT_CONFIG = {
    general: {
      name: nil,
      repo: nil,
      workdir: nil,
      relative_path: '',
      quiet: false,
      diff: false
    },
    smtp: {
      enabled: false,
      from: nil,
      to: nil,
      server: nil,
      port: nil
    },
    brakeman: {
      enabled: true
    },
    codesake_dawn: {
      enabled: true
    },
    bundler_audit: {
      enabled: true
    }
  }

  def self.from_hash(hash)
    new.recursive_merge! hash.deep_symbolize_keys
  end

  def self.from_yaml(yaml_string)
    from_hash(YAML.load(yaml_string, safe: true))
  end

  def initialize
    super
    self.merge! DEFAULT_CONFIG
  end
end
