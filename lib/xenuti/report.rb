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

  def self.load(filename)
    YAML.load(File.new(filename).read, safe: true, deserialize_symbols: true)
  end

  def self.reports_dir(config)
    config.general.tmpdir + '/reports'
  end

  def self.latest_report(config)
    reportfiles = Dir.glob reports_dir(config) + '/*'
    latest_time = Time.at(0)
    latest = nil
    reportfiles.each do |reportfile|
      report = YAML.load(File.new(reportfile).read, safe: false)
      latest = report[:scan_info][:start_time] > latest_time ? report : latest
      latest_time = latest.scan_info.start_time
    end
    latest
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

  def save
    Dir.mkdir reports_dir(config) unless Dir.exist? reports_dir(config)
    filename = reports_dir(config) + '/' + Time.now.to_datetime.rfc3339
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
    start time: #{older_report.scan_info.start_time}
    revision:   #{older_report.config.general.revision}
    EOF
  end

  def formatted_header_end_banner
    '#' * 55 + "\n"
  end

  def duration
    (scan_info.end_time - scan_info.start_time).round(2)
  end

  def diff!(older_report)
    return unless older_report.is_a? Xenuti::Report
    @diffed = true
    self[:older_report] = older_report
    scanner_reports.each do |sr|
      scanner_name = sr.scan_info.scanner_name
      old_sr = self.class.find_scanner_report(older_report, scanner_name)
      sr.diff!(old_sr)
    end
  end

  def diffed?
    @diffed == true
  end

  def reports_dir(config)
    self.class.reports_dir(config)
  end
end
