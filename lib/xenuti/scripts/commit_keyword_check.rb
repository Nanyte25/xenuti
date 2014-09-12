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

opts = {'keyword' => [], 'author' => [], 'diff' => [],
  'case_insensitive' => false }

optparse = OptionParser.new do |options|

  options.on('-v', '--version', 'Version of the script') do
    puts VERSION
    exit
  end

  options.on('-k', '--keyword KEYWORD',
             'Keyword to search for in commits') do |keyword|
    opts['keyword'] << keyword
  end

  options.on('-d', '--diff-keyword KEYWORD',
             'Keyword to search for in commit`s diff') do |keyword|
    opts['diff'] << keyword
  end

  options.on('-a', '--author-keyword KEYWORD',
             'Keyword to search for in commit`s author field') do |keyword|
    opts['author'] << keyword
  end

  options.on('-i', '--case-insensitive', 'Case insensitive match') do
    opts['case_insensitive'] = true
  end

  options.on('-f', '--config-file FILE', 'Path to file with JSON config') do |f|
    opts['config_file'] = f
  end
end

optparse.parse!
gitrepo = ARGV.pop

if gitrepo.nil?
  $stderr.puts 'Please supply path to a git repo.'
  exit(1)
end

# When config file was supplied, load it and override all opts.
if opts['config_file']
  begin
    opts = opts.merge JSON.load IO.read opts['config_file']
  rescue Exception => e
    $stderr.puts e
    exit(1)
  end
end


$stderr.puts opts.inspect 

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

  # Given keywords and inputs, returns keyword which matches any of the inputs
  select_matched_keyword = lambda do |keywords, inputs|
    keywords.select do |keyword|
      if opts['case_insensitive']
        regex = Regexp.new keyword, Regexp::IGNORECASE
      else
        regex = Regexp.new keyword
      end
      inputs.any? { |i| i.match(regex) }
    end.first
  end

  matched_keyword = select_matched_keyword.call(opts['keyword'], [commit.author, 
    commit.diff_added, commit.message])

  matched_author = select_matched_keyword.call(opts['author'], [commit.author])

  matched_diff = select_matched_keyword.call(opts['diff'], [commit.diff_added])

  msg = nil
  case 
  when matched_keyword
    msg = {
      trigger: "Commit matched keyword \"#{matched_keyword}\""}

  when matched_author
    msg = {
      trigger: "Commit's author matched \"#{matched_author}\""}

  when matched_diff
    msg = {
      trigger: "Commit's diff matched keyword \"#{matched_diff}\""}

  end

  unless msg.nil?
    msg.merge!(commit: commit.id, author: commit.author, date: commit.date)
    if fetch_url.match(/github.com/)
      msg[:URL] =  URI.join(fetch_url.to_s + '/', 'commit/', commit.id)
    end
    msg[:message] = commit.message
    messages << msg
  end

end

puts JSON.dump messages.to_a
