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

  def mitigate
    @data['whiteboard'].match(/(?<=mitigate=)[^,]*/)
  end

  def needs_cwe?(opts)
    opts[:check_cwe] && cwe.nil? &&
    TRACKED_STATUS.include?(@data['status']) && cvss > opts[:min_cvss]
  end

  # Returns keyword if match was found, nil otherwise
  def mitigate_keyword_match?(opts)
    matched = nil
    if opts[:check_mitigate] && mitigate.nil?
      @data['comments'].each do |comment|
        opts[:mitigate_keywords].each do |keyword|
          m = comment['text'].match /#{keyword}/i
          matched = m unless m.nil?
        end
      end
    end
    matched
  end
end

opts = { min_cvss: 0 , check_mitigate: false, mitigate_keywords: [],
         check_cwe: false }

optparse = OptionParser.new do |options|
  options.on('-v', '--version', 'Version of the script') do
    puts VERSION
    exit
  end

  options.on('--mincvss VALUE', 'Minimum CVSS v2 score for CWE check') do |val|
    min_cvss = val.to_f
    unless 0 <= min_cvss && min_cvss <= 10
      $stderr.puts "CVSS score expected to be in <0, 10>, was #{min_cvss}"
      exit(3)
    end
    opts[:min_cvss] = min_cvss
  end

  options.on('--cwe', 'Report missing CWE score') do
    opts[:check_cwe] = true
  end

  options.on('--mitigate', 'Report missing mitigate=') do
    opts[:check_mitigate] = true
  end

  options.on('--mitigate-keyword KEYWORD', 'Keyword to look for in comments') do |keyword|
    opts[:mitigate_keywords] << keyword.downcase
  end
end

optparse.parse!
flaws_json = ARGV.pop

if flaws_json.nil?
  $stderr.puts 'Please supply path to a flaws json file.'
  exit(1)
end

if opts[:check_mitigate] && opts[:mitigate_keywords].empty?
  $stderr.puts 'Please supply mitigate keywords to look for in comments'
  exit(2)
end

flaws = JSON.load IO.read flaws_json
flaws.map! { |flaw_hash| Flaw.new(flaw_hash) }
need_cwe = []

flaws.select do |flaw|
  if flaw.needs_cwe?(opts)
    need_cwe << {
      reason: 'Flaw is missing cwe=',
      id: flaw.data['id'], summary: flaw.data['summary'],
      status: flaw.data['status'], resolution: flaw.data['resolution'],
      url: "https://bugzilla.redhat.com/show_bug.cgi?id=#{flaw.data['id']}" }
  end

  if keyword = flaw.mitigate_keyword_match?(opts)
    need_cwe << {
      reason: "Flaw is missing mitigate=. Matched keyword #{keyword}",
      id: flaw.data['id'], summary: flaw.data['summary'],
      status: flaw.data['status'], resolution: flaw.data['resolution'],
      url: "https://bugzilla.redhat.com/show_bug.cgi?id=#{flaw.data['id']}" }
  end
end

puts JSON.dump need_cwe
