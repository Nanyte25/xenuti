#!/usr/bin/env ruby

# Copyright (C) 2014 Jan Rusnacko
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of the
# MIT license.

require 'json'
require 'optparse'
require 'set'
require 'uri'

VERSION = '0.1.0'

class Commit
  attr_reader :id, :author, :message, :diff, :diff_added, :date
  attr_accessor :trigger

  def initialize(string)
    @id = string.match(/[a-f0-9]+/).to_s
    @author = string.match(/(?<=Author: )[^\n]*/).to_s
    @date = string.match(/(?<=Date:   )[^\n]*/).to_s
    @message = ''
    @diff = ''
    parse_message_diff(string)
    @diff_added = parse_diff_added(@diff)
    $stderr.puts "Commit #{@id} diff: #{@diff_added}\n#{'=' * 20}"
  end

  private

  # Given full commit, this will parse diff and store it in @diff
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

  # Given full diff, filter out only lines added 
  def parse_diff_added(diff)
    diff.lines.select {|l| l.match /^\+[^+].*/}.join
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

old_pwd = Dir.pwd
begin
  Dir.chdir gitrepo
  fetch_url = %x(git remote show origin).match(/(?<=Fetch URL: ).*/).to_s
  fetch_url.gsub!('.git', '')
  # Dirty hack - since the split has lookahead for \n, first 'commit' would not
  # be removed
  output = "\n" + %x(git log -p --date=iso8601 --since=2.weeks)
ensure
  Dir.chdir old_pwd
end

output.split(/(?<=\n)commit/).each do |commit_plain|
  commit = Commit.new(commit_plain)
  matched_keyword = nil

  case
  when opts[:keyword].any? { |k| commit_plain.match k }
    matched_keyword = opts[:keyword].select do |k|
      commit.author.match(k) ||
      commit.diff_added.match(k) ||
      commit.message.match(k)
    end.first

  when opts[:author].any? { |a| commit.author.match a }
    matched_keyword = opts[:author].select { |k| commit.author.match k }.first

  when opts[:diff].any? { |d| commit.diff.match d }
    matched_keyword = opts[:diff].select { |k| commit.diff_added.match k }.first
  end

  if matched_keyword
    msg = {
      trigger: "Commit matched keyword \"#{matched_keyword}\"",
      commit: commit.id, author: commit.author, date: commit.date }
    if fetch_url.match(/github.com/)
      msg[:URL] =  URI.join(fetch_url.to_s + '/', 'commit/', commit.id)
    end
    msg[:message] = commit.message
    messages << msg
  end

end

puts JSON.dump messages.to_a
