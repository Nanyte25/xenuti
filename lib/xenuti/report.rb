# Copyright (C) 2014 Jan Rusnacko
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of the
# MIT license.

require 'ruby_util/hash_with_method_access'
require 'ruby_util/hash_with_constraints'

class Xenuti::Report < Hash
  include HashWithMethodAccess
  include HashWithConstraints

  attr_accessor :config

  def initialize
    self[:scan_info] = { version: Xenuti::Version }

    self[:scanner_reports] = []
  end

  # TODO: refactor
  # rubocop:disable MethodLength
  def formatted(config)
    report = <<-EOF.unindent
    #############################################
                   XENUTI REPORT
    #############################################
    version:    #{scan_info.version}
    start time: #{scan_info.start_time}
    end time:   #{scan_info.end_time}
    duration:   #{duration} s

    name:       #{config.general.name}
    repo:       #{config.general.repo}
    #############################################

    EOF
    scanner_reports.each do |scanner_report|
      report << scanner_report.formatted + "\n"
    end
    report
  end
  # rubocop:enable MethodLength

  def duration
    (scan_info.end_time - scan_info.start_time).round(2)
  end
end
