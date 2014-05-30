# Copyright (C) 2014 Jan Rusnacko
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of the
# MIT license.

class Xenuti::Repository
  class << self
    # TODO: add git to dependencies

    def fetch_source(cfg, destination)
      destination = File.expand_path(destination)
      if git_repo?(destination)
        update(destination)
      else
        clone(cfg.general.repo, destination)
      end
      cfg.general.source = destination
      cfg.general.revision = revision(destination)
      cfg.general.app_dir = app_dir(destination, cfg.general.relative_path)
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

    def revision(dir)
      cwd = Dir.pwd
      begin
        Dir.chdir dir
        return %x(git rev-parse --verify HEAD).strip
      ensure
        Dir.chdir cwd
      end
    end

    def app_dir(root_dir, relative_path)
      File.expand_path(root_dir) << '/' + (relative_path ? relative_path : '')
    end
  end
end
