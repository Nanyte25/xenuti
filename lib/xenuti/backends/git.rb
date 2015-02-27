#!/usr/bin/env ruby

# Copyright (C) 2014 Jan Rusnacko
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of the
# MIT license.

require 'optparse'
require 'fileutils'
require 'json'

VERSION = '0.0.1'
DESTINATION = 'git_source'

def git_repo?(dir)
  cwd = Dir.pwd
  return false unless Dir.exist? dir
  begin
    Dir.chdir dir
    %x(git status 2>&1)
    return true if $?.exitstatus == 0
    return false
  ensure
    Dir.chdir cwd
  end
end

def git_revision(dir)
  cwd = Dir.pwd
  begin
    Dir.chdir dir
    return %x(git rev-parse --verify HEAD).strip
  ensure
    Dir.chdir cwd
  end
end

def git_clone(source, destination)
  $stderr.puts "Cloning #{source} to #{destination} ..."
  %x(git clone #{source} #{destination} 2>&1)
  fail 'Git clone failed' if $?.exitstatus != 0
  $stderr.puts '... cloning done.'
end

def git_update(git_repo)
  $stderr.puts "Updating git repository #{git_repo} ..."
  cwd = Dir.pwd
  begin
    Dir.chdir git_repo
    %x(git pull 2>&1)
    fail 'Git pull failed' if $?.exitstatus != 0
  ensure
    Dir.chdir cwd
  end
  $stderr.puts '... update done.'
end

    
options = {}
OptionParser.new do |opts|
  opts.on('-v', '--version', 'Version of the script') do
    puts VERSION
    exit
  end

  opts.on('-r', '--repository URL', 'URL of repository to clone') do |r|
    options[:repository] = r
  end
end.parse!

workdir = ARGV.pop

if workdir.nil?
  fail 'Please supply path to work directory.'
end

destination = File.expand_path(File.join(workdir, DESTINATION))
FileUtils.mkdir_p destination

if git_repo?(destination)
  git_update(destination)
else
  git_clone(options[:repository], destination)
end

revision = git_revision(destination)

puts JSON.dump({ source: destination, revision: revision })