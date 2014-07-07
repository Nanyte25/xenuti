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

class Xenuti::Config < Hash
  include HashWithMethodAccess
  include HashWithConstraints

  ANNOTATED_DEFAULT_CONFIG = <<-EOF.unindent
    ---
    general:
      name:               # Name of the project to scan - appears in report
      repo:               # Path to Git repository
      workdir:            # Working directory for Xenuti - holds reports,
                          # sources.. Don't change in diff mode between runs.
      relative_path: ''   # Relative path to web application within repository
      quiet: false        # Suppress output
      diff: false         # Diff mode - include only new warnings in report
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
