# Copyright (C) 2014 Jan Rusnacko
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of the
# MIT license.

class Xenuti::ContentUpdate::Git
  class << self
    # TODO: add git to dependencies

    def update(config, report)
      destination = File.join(config[:general][:workdir], 'source')
      destination = File.expand_path(destination)
      # TODO: error check for non-empty dir
      if git_repo?(destination)
        git_update(destination)
      else
        git_clone(config[:content_update][:repo], destination)
      end
      config[:content_update][:source] = destination
      config[:content_update][:revision] = git_revision(destination)
      report.scan_info.revision = config[:content_update][:revision]
    end

    def git_clone(source, destination)
      $log.info "Cloning #{source} to #{destination} ..."
      %x(git clone #{source} #{destination} 2>&1)
      fail 'Git clone failed' if $?.exitstatus != 0
      $log.info '... cloning done.'
    end

    def git_update(git_repo)
      $log.info "Updating git repository #{git_repo} ..."
      cwd = Dir.pwd
      begin
        Dir.chdir git_repo
        %x(git pull 2>&1)
        fail 'Git pull failed' if $?.exitstatus != 0
      ensure
        Dir.chdir cwd
      end
      $log.info '... update done.'
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

    def git_revision(dir)
      cwd = Dir.pwd
      begin
        Dir.chdir dir
        return %x(git rev-parse --verify HEAD).strip
      ensure
        Dir.chdir cwd
      end
    end
  end
end
