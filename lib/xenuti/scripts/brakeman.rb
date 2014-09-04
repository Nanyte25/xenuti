#!/usr/bin/env ruby

# Copyright (C) 2014 Jan Rusnacko
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of the
# MIT license.

require 'json'

if ARGV[0].nil?
  $stderr.puts 'Please supply path to Rails Application.'
  exit(1)
end

if ARGV[0].strip == '-v'
  puts %x(brakeman -v).match(/[0-9].[0-9].[0-9]/)
  exit
end

if ARGV.size > 1
  $stderr.puts 'More than 1 arguments were specified.'
  exit(2)
end

begin
  output = JSON.load(%x(brakeman -q -f json #{ARGV[0]}))
rescue JSON::ParserError
  $stderr.puts "Could not parse Brakeman output. Path supplied: #{ARGV[0]}"
end
puts JSON.dump(output['warnings'])
