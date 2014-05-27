# Copyright (C) 2014 Jan Rusnacko
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of the
# MIT license.

require 'spec_helper'

describe Xenuti::ScannerReport do
  let(:report) do
    # Some data to fill in the report
    r = Xenuti::ScannerReport.new
    r.scan_info.start_time = Time.now
    r.scan_info.end_time = Time.now
    r.scan_info.duration = 1.1
    r.scan_info.scanner_name = 'foo'
    r.scan_info.scanner_version = '1.2.3'
    r.scan_info.warnings = 2
    r.warnings = [
      Xenuti::Warning.new.merge!(name: :failure),
      Xenuti::Warning.new.merge!(error: :occured)
    ]
    r
  end

  it_behaves_like 'hash with method access', Xenuti::ScannerReport.new
end
