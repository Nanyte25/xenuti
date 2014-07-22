# Copyright (C) 2014 Jan Rusnacko
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of the
# MIT license.

require 'json'

class Xenuti::Brakeman
  include Xenuti::StaticAnalyzer

  class Warning < Xenuti::Warning
    CONFIDENCE = %w(High Medium Weak)

    def <=>(other)
      CONFIDENCE.index(confidence) <=> CONFIDENCE.index(other.confidence)
    end
  end

  # Check requirements for running this scanner - throws RuntimeError if any of
  # the requirements are not met. Returns true when requirements are met.
  def self.check_requirements(_config)
    %x(whereis brakeman | grep '/')
    xfail 'Brakeman: could not find executable' if $?.exitstatus != 0

    $log.info 'Brakeman: check_requirements passed'
    true
  end

  def self.name
    'brakeman'
  end

  def self.version
    @version ||= %x(brakeman -v).match(/\d\.\d\.\d/).to_s
  end

  def self.check_config(config)
    config.verify do
      config.general.relative_path.each do |relpath|
        app_dir = File.join(config.general.source, relpath)
        xfail "Directory #{app_dir} does not exist" unless Dir.exist? app_dir
      end
    end
    $log.info 'Brakeman: configuration check passed'
    true
  end

  def self.execute_scan(config, app_dir)
    xfail 'Brakeman is disabled' unless config.brakeman.enabled
    $log.info "Brakeman: starting scan of #{app_dir}"
    output = %x(brakeman -q -f json #{app_dir})
    $log.info 'Brakeman: scan finished'
    output
  end

  def self.parse_results(json_output)
    report = Xenuti::ScannerReport.new
    JSON.load(json_output)['warnings'].each do |warn_hash|
      report.warnings << Xenuti::Brakeman::Warning.from_hash(warn_hash)
    end
    report
  end
end
