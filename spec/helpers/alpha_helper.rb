# Copyright (C) 2014 Jan Rusnacko
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of the
# MIT license.

# Require this file to dynamically create a git repo with Rails 3 application.
# It will also generate alpha_config.yml file with repo pointing to generated
# Rails 3 application repo.
#
# Generated alpha_config.yml enables all static analyzers.

require 'tmpdir'
require 'ruby_util/string'
require 'fileutils'

ALPHA_REPO = Dir.mktmpdir
ALPHA_TMPDIR = Dir.mktmpdir

FileUtils.cp_r(FIXTURES + '/alpha/.', ALPHA_REPO)

old_pwd = Dir.pwd
Dir.chdir(ALPHA_REPO)
%x(git init; git add -f *; git add .gitignore; git commit -m "Initial commit.")
Dir.chdir(old_pwd)

File.open(FIXTURES + '/alpha_config.yml', 'w+') do |file|
  file.write <<-EOF.unindent
    ---
    general:
      repo: #{ALPHA_REPO}
      tmpdir: #{ALPHA_TMPDIR}
    brakeman:
      enabled: true
      options:
    codesake_dawn:
      enabled: true
    bundler_audit:
      enabled: true
  EOF
end

at_exit do
  FileUtils.rm_rf(ALPHA_REPO)
  FileUtils.rm_rf(ALPHA_TMPDIR)
end
