#!/usr/bin/env ruby

# Copyright (C) 2014 Jan Rusnacko
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of the
# MIT license.

require 'json'
require 'optparse'

VERSION = '1.2.3'

OptionParser.new do |options|
  options.on('-v', '--version', 'Version of the script') do
    puts VERSION
    exit
  end
end.parse!

puts JSON.dump([{'message' => "Error##{rand(10)}", 'line' => "#{rand(1000)}"}])