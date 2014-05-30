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
      scanner_name: nil, scanner_version: nil, exception: nil }

    self[:warnings] = []
  end

  def formatted
    report = formatted_header
    report << formatted_warnings unless scan_info.exception
    report
  end

  def formatted_header
    header = <<-EOF.unindent
    ==============================
    scanner:  #{scan_info.scanner_name}
    version:  #{scan_info.scanner_version}
    duration: #{scan_info.duration} s
    EOF
    header << formatted_header_exception if scan_info.exception
    header << formatted_header_end_banner
  end

  def formatted_header_exception
    "\nERROR: " + scan_info.exception.message + "\n"
  end

  def formatted_header_end_banner
    '=' * 30 + "\n"
  end

  def formatted_warnings
    output = ''
    warns_to_print = diffed? ? new_warnings : warnings
    if warns_to_print.size == 0
      output << "No new warnings.\n"
    else
      warns_to_print.sort.each do |warning|
        output << warning.formatted + "\n"
      end
    end
    output
  end

  def diff!(older_report)
    self[:new_warnings] = warnings - older_report.warnings
    self[:fixed_warnings] = older_report.warnings - warnings
  end

  def diffed?
    return true if self[:new_warnings] && self[:fixed_warnings]
    false
  end
end
