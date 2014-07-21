# Copyright (C) 2014 Jan Rusnacko
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of the
# MIT license.

def xfail(message)
  $log.error message
  fail message
end

module Xenuti
end

require 'xenuti/version'
require 'xenuti/config'
require 'xenuti/repository'
require 'xenuti/scanner_report'
require 'xenuti/warning'
require 'xenuti/report'
require 'xenuti/report_sender'
require 'xenuti/scanners/scanner'
require 'xenuti/scanners/brakeman'
require 'xenuti/scanners/codesake_dawn'
require 'xenuti/scanners/bundler_audit'
require 'xenuti/processor'
require 'xenuti/deployer'
