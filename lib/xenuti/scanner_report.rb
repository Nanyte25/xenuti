# Copyright (C) 2014 Jan Rusnacko
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of the
# MIT license.

require 'ruby_util/hash'
require 'ruby_util/string'
require 'ruby_util/hash_with_method_access'
require 'ruby_util/hash_with_constraints'

class Xenuti::ScannerReport < Hash
  include HashWithMethodAccess
  include HashWithConstraints

  def initialize
    self[:scan_info] = {
      start_time: nil, end_time: nil, duration: nil,
      scanner_name: nil, scanner_version: nil }

    self[:warnings] = []
  end

  # TODO: refactor
  # rubocop:disable MethodLength
  # rubocop:disable CyclomaticComplexity
  def formatted
    report = <<-EOF.unindent
    ============================
    scanner:  #{scan_info.scanner_name}
    version:  #{scan_info.scanner_version}
    duration: #{scan_info.duration} s
    ============================
    EOF
    warnings.sort.each do |warning|
      report << warning.formatted + "\n"
    end
    report
  end
  # rubocop:enable MethodLength
  # rubocop:enable CyclomaticComplexity
end
