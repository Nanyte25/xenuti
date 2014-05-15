# Copyright (C) 2014 Jan Rusnacko
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of the
# MIT license.

require 'ruby_util/hash'
require 'ruby_util/hash_with_method_access'
require 'ruby_util/hash_with_constraints'

class Xenuti::Report < Hash
  include HashWithMethodAccess
  include HashWithConstraints

  # rubocop:disable MethodLength
  def initialize
    self[:scan_info] = {
      start_time: nil, end_time: nil, duration: nil,
      scanner_name: nil, scanner_version: nil }

    self[:warnings] = []

    constraints do
      fail unless scan_info.start_time.is_a? Time
      fail unless scan_info.end_time.is_a? Time
      fail unless scan_info.duration.is_a? Float
      fail unless scan_info.scanner_name.is_a? String
      fail unless scan_info.scanner_version.is_a? String
    end
  end
  # rubocop:enable MethodLength
end
