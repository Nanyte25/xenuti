#!/usr/bin/env ruby

# Copyright (C) 2014 Jan Rusnacko
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of the
# MIT license.
require 'json'
require 'optparse'

# Only bugs with tracked status will be reported
TRACKED_STATUS = %w(CLOSED VERIFIED)

# vesion of this script
VERSION = '1.0.0'

class Flaw
  attr_reader :data

  def initialize(data)
    @data = data
  end

  def cwe
    match = @data['whiteboard'].match(/cwe=[^,]*/)
    match ? match.to_s : nil
  end

  # Returns CVSS score as Float
  def cvss
    @data['whiteboard'].match(/(?<=cvss2=)[^,]*/).to_s.to_f
  end
end

opts = { min_cvss: 0 }

optparse = OptionParser.new do |options|
  options.on('-v', '--version', 'Version of the script') do
    puts VERSION
    exit
  end

  options.on('-c', '--cvss VALUE', 'Minimum CVSS v2 score') do |val|
    min_cvss = val.to_f
    unless 0 <= min_cvss && min_cvss <= 10
      $stderr.puts "CVSS score expected to be in <0, 10>, was #{min_cvss}"
      exit(2)
    end
    opts[:min_cvss] = min_cvss
  end
end

optparse.parse!
flaws_json = ARGV.pop

if flaws_json.nil?
  $stderr.puts 'Please supply path to a flaws json file.'
  exit(1)
end

flaws = JSON.load IO.read flaws_json
flaws.map! { |flaw_hash| Flaw.new(flaw_hash) }
need_cwe = []

flaws.select do |flaw|
  if flaw.cwe.nil? &&
     TRACKED_STATUS.include?(flaw.data['status']) &&
     flaw.cvss > opts[:min_cvss]
    need_cwe << {
      id: flaw.data['id'], summary: flaw.data['summary'],
      url: "https://bugzilla.redhat.com/show_bug.cgi?id=#{flaw.data['id']}" }
  end
end

puts JSON.dump need_cwe
