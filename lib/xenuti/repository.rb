# Copyright (C) 2014 Jan Rusnacko
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of the
# MIT license.

class Xenuti::Repository
  class << self
    # TODO: add git to dependencies

    def fetch_source(config, destination)
      if git_repo?(destination)
        update(destination)
      else
        clone(config.general.repo, destination)
      end
      config.general.source = destination
    end

    def clone(source, destination)
      %x(git clone #{source} #{destination} 2>&1)
      fail 'Git clone failed' if $?.exitstatus != 0
    end

    def update(git_repo)
      cwd = Dir.pwd
      begin
        Dir.chdir git_repo
        %x(git pull 2>&1)
        fail 'Git pull failed' if $?.exitstatus != 0
      ensure
        Dir.chdir cwd
      end
    end

    def git_repo?(dir)
      cwd = Dir.pwd
      return false unless Dir.exists? dir
      begin
        Dir.chdir dir
        %x(git status 2>&1)
        return true if $?.exitstatus == 0
        return false
      ensure
        Dir.chdir cwd
      end
    end
  end
end
