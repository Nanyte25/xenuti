# Copyright (C) 2014 Jan Rusnacko
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of the
# MIT license.

require 'safe_yaml'
require 'ruby_util/hash'
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
  include HashWithConstraints

  # This annotated config is returned by 'xenuti generate_config'. To avoid
  # repetition and necessity to keep two places synchronized and up-to-date, it
  # is parsed and used to define DEFAULT_CONFIG (see below), which is used to
  # initialize values not specified explicitly.
  ANNOTATED_DEFAULT_CONFIG = <<-EOF.unindent
    ---
    general:
      name:                   # Name of the project to scan - appears in report
      workdir:                # Working directory for Xenuti - holds reports,
                              # sources.. Don't change in diff mode between runs
      scriptdir:              # Directory with custom scripts
      backenddir:             # Directory with custom backends
      quiet: false            # Suppress output
      loglevel: warn          # One of: fatal, error, warn, info, debug

    content_update:
      backend:                # name of the backend
      args:                   # Command line arguments passed to script

    process:
      myscript:
        args:                 # Command line arguments passed to script
        abort_on_fail: false  # Abort run if the script fails
        diff: false           # Diff mode - include only new warnings in report
        relative_path: ['']   # Relative path(s) to dir within repository
        diff_ignore: []       # Which message fields to ignore during diff
        sort_field:           # Name of field on which messages will be sorted

    report:
      send_mail: false        # Enable to send report via mail
      skip_empty: false       # Skip sending if the report is empty
      from:                   # From mail address
      to:                     # Destination - either mail address or array of
                              # mail addresses to send report to.
      server:                 # SMTP server to use
      port:                   # SMTP port to use
  EOF

  DEFAULT_CONFIG = YAML.load(ANNOTATED_DEFAULT_CONFIG, safe: false)
  DEFAULT_CONFIG.deep_stringify_keys!

  def self.from_hash(hash)
    new.recursive_merge!(hash.deep_stringify_keys).fill_default_values
  end

  def self.from_yaml(yaml_string)
    from_hash(YAML.load(yaml_string, safe: true))
  end

  def initialize
    super
  end

  def fill_default_values
    self['process'] ||= {}
    self['general'] ||= {}
    self['content_update'] ||= {}
    self['report'] ||= {}

    self['general'].soft_merge! DEFAULT_CONFIG['general']

    self['report'].soft_merge! DEFAULT_CONFIG['report']

    self['process'].each do |script, script_cfg|
      script_cfg.soft_merge! DEFAULT_CONFIG['process']['myscript']
    end

    # convert script names back to strings
    # self[:process] = Hash[self[:process].map {|k,v| [k.to_s, v]}]

    self
  end
end
