# Copyright (C) 2014 Jan Rusnacko
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of the
# MIT license.

module Xenuti
  SCRIPTS = {
    brakeman: 'brakeman.rb',
    commit_keyword_check: 'commit_keyword_check.rb',
    flaws_check: 'flaws_check.rb',
    selinux_cwe_warning: 'selinux_cwe_warning.rb'
  }

  scripts_folder = File.dirname(__FILE__)
  SCRIPTS.each do |name, file|
    SCRIPTS[name] = File.join(scripts_folder, file)
  end
end
