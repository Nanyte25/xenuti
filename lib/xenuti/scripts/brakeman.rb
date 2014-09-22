#!/usr/bin/env ruby

# Copyright (C) 2014 Jan Rusnacko
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of the
# MIT license.

require 'json'
require 'uri'

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

# Get URL of repo and revision
old_pwd = Dir.pwd
begin
  Dir.chdir ARGV[0]
  fetch_url = %x(git remote show origin).match(/(?<=Fetch URL: ).*/).to_s
  fetch_url.gsub!('.git', '')
  revision = %x(git rev-parse HEAD).strip

  # get relpath if any
  relpath = ARGV[0].dup
  relpath.slice! %x(git rev-parse --show-toplevel).strip
  relpath += "/" if relpath
ensure
  Dir.chdir old_pwd
end


begin
  output = JSON.load(%x(brakeman -q -f json #{ARGV[0]}))
rescue JSON::ParserError
  $stderr.puts "Could not parse Brakeman output. Path supplied: #{ARGV[0]}"
end

if fetch_url.match(/github.com/)
  output['warnings'].each do |warning|

    # If Brakeman warning specifies a file, include URL pointing to that file
    if warning['file'].split(',').size == 1
      warning['URL'] = File.join(fetch_url.to_s, 'blob', revision, relpath, warning['file'])

      # If warning contains line, add it to the URL
      warning['URL'] += '#L' + warning['line'].to_s if warning['line']

      # If warning is of type "Mass Assignment"
      if warning['warning_code'] == 60

        File.open(File.join(ARGV[0], warning['file'])) do |f|
          l = f.readlines.map(&:strip)
          h = Hash[l.zip((1..l.size).to_a)]   # {"line" => line number, ..}
          c = l.join("\n")                    # whole content in one string
          p = c.match(/attr_accessible (:[a-zA-Z_]*)(,\s+:[a-zA-Z_]*)*/m).to_s
          p.split("\n").each do |line|
            if line.match /#{warning['code']}/
              warning['URL'] += '#L' + h[line.strip].to_s
            end
          end
        end
      end
    end
  end
end

puts JSON.dump(output['warnings'])
