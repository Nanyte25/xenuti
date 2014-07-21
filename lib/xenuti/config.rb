# Copyright (C) 2014 Jan Rusnacko
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of the
# MIT license.

require 'safe_yaml'
require 'ruby_util/hash'
require 'ruby_util/hash_with_method_access'
require 'ruby_util/hash_with_constraints'
require 'ruby_util/string'

# Xenuti::Config is a single point of truth during run. Other classes may add or
# modify keys stored here during execution.
#
# It is a subclass of Hash, but also includes HashWithMethodAccess module. This
# means entries can be accessed both by Hash-like syntax and as a methods. For
# example, given config like
#
#     config = { :nested => { :key => :value } }
#
# we can retrieve value of key in two ways:
#
#     config[:nested][:key]
#     config.nested.key
#
# This works by overloading #method_missing and returning value of the key if
# key of such name exists. If the key of such name does not exists,
# NoMethodError is thrown.
#
# Such method has two gotchas:
# * New keys cannot be defined, hash syntax must be used
# * Names of keys may collide with actual method names
#
# When possible, I use this method cause it just seems nice to me.
#
# Additionally, HashWithConstraints module is also included. This makes it
# possible to specify a block with constraints passed to #constraints method,
# and invoke check calling #check method. This works only if blocks passed raise
# errors. If constraints should not be saved, but we need one-time-only check,
# use #verify method.
class Xenuti::Config < Hash
  include HashWithMethodAccess
  include HashWithConstraints

  # This annotated config is returned by 'xenuti generate_config'. To avoid
  # repetition and necessity to keep two places synchronized and up-to-date, it
  # is parsed and used to define DEFAULT_CONFIG (see below), which is used to
  # initialize values not specified explicitly.
  ANNOTATED_DEFAULT_CONFIG = <<-EOF.unindent
    ---
    general:
      name:               # Name of the project to scan - appears in report
      repo:               # Path to Git repository
      workdir:            # Working directory for Xenuti - holds reports,
                          # sources.. Don't change in diff mode between runs.
      relative_path: ''   # Relative path to web application within repository
      quiet: false        # Suppress output
      loglevel: warn      # One of: fatal, error, warn, info, debug
      diff: false         # Diff mode - include only new warnings in report
    active_scan:
      deploy_script:      # Path to deploy script
      cleanup_script:     # Path to cleanup script
      deploy_variables:   # String of comma-separated environment variables
      cleanup_variables:  # String of comma-separated environment variables
      url:                # URL where application will be deployed
    smtp:
      enabled: false      # Enable to send report by mail
      from:               # From mail address
      to:                 # Destination - either mail address or array of
                          # mail addresses to send report to.
      server:             # SMTP server to use
      port:               # SMTP port to use
    brakeman:
      enabled: true       # Enable to run Brakeman
    codesake_dawn:
      enabled: true       # Enable to run Codesake Dawn
    bundler_audit:
      enabled: true       # Enable to run Bundler Audit
  EOF

  # Define DEFAULT_CONFIG stripped out of comments
  DEFAULT_CONFIG = YAML.load(ANNOTATED_DEFAULT_CONFIG, safe: false)

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
