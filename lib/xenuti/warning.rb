# Copyright (C) 2014 Jan Rusnacko
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of the
# MIT license.

require 'ruby_util/hash'
require 'ruby_util/hash_with_method_access'
require 'ruby_util/hash_with_constraints'

class Xenuti::Warning < Hash
  include HashWithMethodAccess
  include HashWithConstraints

  def initialize(hash)
    self.merge! hash.deep_symbolize_keys
  end
end