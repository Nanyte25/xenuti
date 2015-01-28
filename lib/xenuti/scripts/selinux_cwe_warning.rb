#!/usr/bin/env ruby

# Copyright (C) 2014 Jan Rusnacko
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of the
# MIT license.
require 'json'

# Only bugs with these CWEs are reported
TRACKED_CWES = {
  'CWE-377' => 'Insecure Temporary File',
  'CWE-476' => 'NULL Pointer Dereference',
  'CWE-732' => 'Incorrect Permission Assignment for Critical Resource',
  'CWE-611' => 'Improper Restriction of XML External Entity Reference (\'XXE\')'}

# vesion of this script
VERSION = '1.0.0'

class Flaw
  attr_reader :data

  def initialize(data)
    @data = data
  end

  def cwe
    match = @data['whiteboard'].match(/(?<=cwe=)[^,]*/)
    match ? match.to_s : nil
  end
end

flaws_json = ARGV.pop

if flaws_json.nil?
  $stderr.puts 'Please supply path to a flaws json file.'
  exit(1)
end

flaws = JSON.load IO.read flaws_json
flaws.map! { |flaw_hash| Flaw.new(flaw_hash) }

report = []

flaws.select {|f| !f.cwe.nil? }.each do |flaw|
  if TRACKED_CWES.keys.any? { |tracked_cwe| flaw.cwe.match(tracked_cwe) }
    report << {
      reason: "Flaw's cwe matched one of the tracked values.",
      id: flaw.data['id'], 
      summary: flaw.data['summary'],
      flaw_cwe: flaw.cwe,
      url: "https://bugzilla.redhat.com/show_bug.cgi?id=#{flaw.data['id']}"
    }
  end
end

puts JSON.dump report