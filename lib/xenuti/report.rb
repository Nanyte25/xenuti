# Copyright (C) 2014 Jan Rusnacko
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of the
# MIT license.

require 'ruby_util/hash_with_method_access'
require 'ruby_util/hash_with_constraints'
require 'date'

class Xenuti::Report < Hash
  include HashWithMethodAccess
  include HashWithConstraints

  attr_accessor :diffed

  REPORT_NAME = 'report.yml'

  # TODO: figure out SafeYAML to call this with safe: true
  def self.load(filename)
    YAML.load(File.new(filename).read, safe: false)
  end

  def self.prev_report(config)
    reportfiles = Dir.glob config.general.workdir + '/reports/**/' + REPORT_NAME
    latest_time = Time.at(0)
    latest = nil
    reportfiles.each do |reportfile|
      report = load(reportfile)
      latest = report[:scan_info][:start_time] > latest_time ? report : latest
      latest_time = latest.scan_info.start_time
    end
    latest
  end

  def self.diff(old_report, new_report)
    report = Xenuti::Report.new
    report.scan_info = new_report.scan_info
    new_report.scanner_reports.each do |new_sr|
      scanner_name = new_sr.scan_info.scanner_name
      old_sr = Xenuti::Report.find_scanner_report(old_report, scanner_name)
      report.scanner_reports << Xenuti::ScannerReport.diff(old_sr, new_sr)
    end
    report.diffed = true
    report.old_report = old_report
    report
  end

  def self.find_scanner_report(report, scanner_name)
    report.scanner_reports.select do |r|
      r.scan_info.scanner_name == scanner_name
    end.first
  end

  def initialize
    self[:scan_info] = { version: Xenuti::Version }
    self[:scanner_reports] = []
    @diffed = false
  end

  def save(config)
    FileUtils.mkdir_p reports_dir(config) unless Dir.exist? reports_dir(config)
    filename = reports_dir(config) + '/' + REPORT_NAME
    File.open(filename, 'w+') do |file|
      file.write(YAML.dump(self))
    end
  end

  def formatted(config)
    report = formatted_header(config)
    scanner_reports.each do |scanner_report|
      report << scanner_report.formatted + "\n"
    end
    report
  end

  def formatted_header(config)
    header = <<-EOF.unindent
    #######################################################
                        XENUTI REPORT
    #######################################################
    EOF
    header << formatted_header_scan_info + "\n"
    header << formatted_header_config_info(config) + "\n"
    header << formatted_header_diff_info + "\n" if diffed?
    header << formatted_header_end_banner + "\n"
  end

  def formatted_header_scan_info
    <<-EOF.unindent
    version:    #{scan_info.version}
    start time: #{scan_info.start_time}
    end time:   #{scan_info.end_time}
    duration:   #{duration} s
    mode:       #{diffed? ? 'diff results' : 'full report'}
    EOF
  end

  def formatted_header_config_info(config)
    <<-EOF.unindent
    name:       #{config.general.name}
    repo:       #{config.general.repo}
    revision:   #{config.general.revision}
    EOF
  end

  def formatted_header_diff_info
    <<-EOF.unindent
    [diffed with]
    start time: #{old_report.scan_info.start_time}
    revision:   #{old_report.scan_info.revision}
    EOF
  end

  def formatted_header_end_banner
    '#' * 55 + "\n"
  end

  def duration
    (scan_info.end_time - scan_info.start_time).round(2)
  end

  def diffed?
    @diffed == true
  end

  def reports_dir(config)
    @dir ||= config.general.workdir + '/reports/' + Time.now.to_datetime.rfc3339
  end
end
