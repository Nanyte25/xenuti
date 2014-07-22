# Copyright (C) 2014 Jan Rusnacko
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of the
# MIT license.

require 'ruby_util/hash'
require 'ruby_util/string'
require 'ruby_util/hash_with_method_access'
require 'ruby_util/hash_with_constraints'
require 'yaml'

class Xenuti::ScannerReport < Hash
  include HashWithMethodAccess
  include HashWithConstraints

  def self.diff(old_report, new_report)
    report = Xenuti::ScannerReport.new
    # TODO: refactor deep clone
    report[:scan_info] = YAML.load(YAML.dump(new_report.scan_info), safe: false)
    report[:warnings] = YAML.load(YAML.dump(new_report.warnings), safe: false)
    report[:new_warnings] = new_report.warnings - old_report.warnings
    report[:fixed_warnings] = old_report.warnings - new_report.warnings
    report
  end

  def initialize
    self[:scan_info] = {
      start_time: nil, end_time: nil, duration: nil, scanner_name: nil,
      scanner_version: nil, exception: nil, relpath: '' }

    self[:warnings] = []
  end

  def formatted
    report = formatted_header
    report << formatted_warnings unless scan_info[:exception]
    report
  end

  def formatted_header
    header = formatted_header_start_banner
    header << "directory: #{scan_info.relpath}\n" unless scan_info.relpath == ''
    header << formatted_header_scan_info
    header << "new warnings:   #{new_warnings.size}\n" if diffed?
    header << "fixed warnings: #{fixed_warnings.size}\n" if diffed?
    header << formatted_header_exception if scan_info[:exception]
    header << formatted_header_end_banner
  end

  def formatted_header_exception
    "\nERROR: " + scan_info.exception.message + "\n"
  end

  def formatted_header_start_banner
    '=' * 30 + "\n"
  end

  def formatted_header_scan_info
    <<-EOF.unindent
    scanner:   #{scan_info.scanner_name}
    version:   #{scan_info.scanner_version}
    duration:  #{scan_info.duration} s

    total warnings: #{warnings.size}
    EOF
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

  def diffed?
    return true if self[:new_warnings] && self[:fixed_warnings]
    false
  end
end
