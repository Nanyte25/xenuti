# Copyright (C) 2014 Jan Rusnacko
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of the
# MIT license.

# Require this file to dynamically create a git repo with Rails 3 application.
# It will also generate alpha_config.yml file with repo pointing to generated
# Rails 3 application repo.
#
# Generated alpha_config.yml disables all static analyzers. This allows to
# enable a particular scanner prior to using config - useful as I don`t want to
# run all scanners just to test one.

require 'tmpdir'
require 'ruby_util/string'
require 'fileutils'

ALPHA_REPO = Dir.mktmpdir
ALPHA_WORKDIR = Dir.mktmpdir
ALPHA_SCRIPTDIR = Dir.mktmpdir
ALPHA_BACKENDDIR = Dir.mktmpdir
ALPHA_CONFIG = File.join(FIXTURES, '/alpha_config.yml')

FileUtils.cp_r(FIXTURES + '/alpha/.', ALPHA_REPO)

old_pwd = Dir.pwd
Dir.chdir(ALPHA_REPO)
%x(git init; git add -f *; git add .gitignore; git commit -m "Initial commit.")
Dir.chdir(old_pwd)

# Create a dummy backend script
File.open(File.join(ALPHA_BACKENDDIR, 'dummy_backend.rb'), 'w+') do |file|
  file.write <<-EOF.unindent
    #!/usr/bin/env ruby

    require 'json'
    require 'tempfile'

    file = Tempfile.new('foo')
    file.write("hello world")

    puts JSON.dump {'source' => file.path, 'backend' => 'dummy_backend'}
  EOF
end

# make the script executable
File.chmod(0744, File.join(ALPHA_BACKENDDIR, 'dummy_backend.rb'))

# Create a dummy custom script
File.open(File.join(ALPHA_SCRIPTDIR, 'dummy_check.rb'), 'w+') do |file|
  file.write <<-EOF.unindent
    #!/usr/bin/env ruby

    require 'json'

    puts JSON.dump [{'message' => 'terrible warning', 'reason' => 'foo'}]
  EOF
end

# make the script executable
File.chmod(0744, File.join(ALPHA_SCRIPTDIR, 'dummy_check.rb'))

File.open(ALPHA_CONFIG, 'w+') do |file|
  file.write <<-EOF.unindent
    ---
    general:
      name: Alpha
      workdir: #{ALPHA_WORKDIR}
      scriptdir: #{ALPHA_SCRIPTDIR}
      backenddir: #{ALPHA_BACKENDDIR}
      quiet: true
      diff: false

    content_update:
      backend: git
      args: >
        --repository #{ALPHA_REPO}

    process:
      brakeman:
        args:

      dummy_check:
        args:

    report:
      send_mail: false
  EOF
end

at_exit do
  FileUtils.rm_rf(ALPHA_REPO)
  FileUtils.rm_rf(ALPHA_WORKDIR)
end
