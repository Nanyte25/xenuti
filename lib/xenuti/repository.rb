# Copyright (C) 2014 Jan Rusnacko
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of the
# MIT license.

class Xenuti::Repository

  class << self
    # Todo: add git to dependencies

    def fetch_source(config, destination)
      if git_repo?(destination)
        update(destination)
      else
        clone(config.general.repo, destination)
      end
    end

    def clone(source, destination)
      %x{git clone #{source} #{destination} 2>&1}
      fail RuntimeError.new if $?.exitstatus != 0
    end

    def update(git_repo)
      cwd = Dir.pwd
      begin
        Dir.chdir git_repo
        %x{git pull 2>&1}
        fail RuntimeError.new if $?.exitstatus != 0
      ensure
        Dir.chdir cwd
      end
    end

    def git_repo?(dir)
      cwd = Dir.pwd
      begin
        Dir.chdir dir
        %x{git status 2>&1}
        if $?.exitstatus == 0
          return true
        else
          return false
        end
      ensure
        Dir.chdir cwd
      end
    end
  end
end