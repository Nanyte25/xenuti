#!/usr/bin/env ruby

# Copyright (C) 2014 Jan Rusnacko
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of the
# MIT license.

require 'json'
require 'optparse'
require 'set'

VERSION = '0.1.0'

class Commit
  attr_reader :id, :author, :message, :diff
  attr_accessor :trigger

  def initialize(string)
    @id = string.match(/[a-f0-9]+/).to_s
    @author = string.match(/(?<=Author: )[^\n]*/).to_s
    @message = ''
    @diff = ''
    parse_message_diff(string)
  end

  private

  def parse_message_diff(string)
    parsing_message_part = true

    string.match(/(?<=\n\n).*/m).to_s.lines.each do |line|
      unless line.match(/^\s{4}/) || line.match(/^\n$/)
        parsing_message_part = false
      end

      if parsing_message_part
        @message << line
      else
        @diff << line
      end
    end
    @message = "\n" + message
  end
end

opts = { keyword: [], author: [], diff: [] }

optparse = OptionParser.new do |options|

  options.on('-v', '--version', 'Version of the script') do
    puts VERSION
    exit
  end

  options.on('-k', '--keyword KEYWORD',
             'Keyword to search for in commits') do |keyword|
    opts[:keyword] << keyword
  end

  options.on('-d', '--diff-keyword KEYWORD',
             'Keyword to search for in commit`s diff') do |keyword|
    opts[:diff] << keyword
  end

  options.on('-a', '--author-keyword KEYWORD',
             'Keyword to search for in commit`s author field') do |keyword|
    opts[:author] << keyword
  end
end

optparse.parse!
gitrepo = ARGV.pop

if gitrepo.nil?
  $stderr.puts 'Please supply path to a git repo.'
  exit(1)
end

messages = Set.new

# Dirty hack - since the split has lookahead for \n, first 'commit' would not
# be removed
output = "\n" + %x(git -C #{gitrepo} log -p --since=2.weeks)

output.split(/(?<=\n)commit/).each do |commit_plain|
  commit = Commit.new(commit_plain)

  case
  when opts[:keyword].any? { |k| commit_plain.match k }
    matched_keyword = opts[:keyword].select { |k| commit_plain.match k }.first
    messages << {
      trigger: "Commit matched keyword #{matched_keyword}",
      commit: commit.id, author: commit.author, message: commit.message }

  when opts[:author].any? { |a| commit.author.match a }
    matched_keyword = opts[:author].select { |k| commit.author.match k }.first
    messages << {
      trigger: "Commit`s author matched #{matched_keyword}",
      commit: commit.id, author: commit.author, message: commit.message }

  when opts[:diff].any? { |d| commit.diff.match d }
    matched_keyword = opts[:diff].select { |k| commit.diff.match k } .first
    messages << {
      trigger: "Commit`s diff matched #{matched_keyword}",
      commit: commit.id, author: commit.author, message: commit.message }
  end
end

puts JSON.dump messages.to_a
