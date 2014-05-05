# Copyright (C) 2014 Jan Rusnacko
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of the
# MIT license.

require 'tmpdir'
require 'fileutils'

ORIGIN_REPO = Dir.mktmpdir
OUTDATED_REPO = Dir.mktmpdir

# Create a git repo with a file and some history
%x{git init #{ORIGIN_REPO}}
File.open("#{ORIGIN_REPO}/test", 'w+') do |file|
  file.write "commit 1\n"
end
%x{pushd #{ORIGIN_REPO}; git add test; git commit -m 'commit1'; popd }

# Clone it to another repo
%x{git clone #{ORIGIN_REPO} #{OUTDATED_REPO} 2>&1}

# .. and add some commit to original repo to make cloned out outdated
File.open("#{ORIGIN_REPO}/test", 'w') do |file|
  file.write "commit 2\n"
end
%x{pushd #{ORIGIN_REPO}; git add test; git commit -m 'commit2'; popd }

at_exit do
  FileUtils.rm_rf(ORIGIN_REPO)
  FileUtils.rm_rf(OUTDATED_REPO)
end