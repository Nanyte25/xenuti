# Copyright (C) 2014 Jan Rusnacko
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of the
# MIT license.

class Xenuti::Deployer
  def self.check_requirements(_config)
    true
  end

  def self.deploy(config)
    $log.info "Running deploy script #{config.active_scan.deploy_script}"
    e = Hash[*config.active_scan.deploy_variables.split(/[,|=]/).map(&:strip)]
    system(e, config.active_scan.deploy_script)
    if $?.exitstatus != 0
      $log.error "Deploy script failed with return code #{$?.exitstatus}"
      false
    else
      true
    end
  end

  def self.cleanup(config)
    $log.info "Running cleanup script #{config.active_scan.cleanup_script}"
    e = Hash[*config.active_scan.cleanup_variables.split(/[,|=]/).map(&:strip)]
    system(e, config.active_scan.deploy_script)
    if $?.exitstatus != 0
      $log.error "Cleanup script failed with return code #{$?.exitstatus}"
      false
    else
      true
    end
  end
end
