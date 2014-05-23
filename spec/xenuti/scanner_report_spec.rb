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
      Xenuti::Warning.new(name: :failure),
      Xenuti::Warning.new(error: :occured)
    ]
    r
  end

  it_behaves_like 'hash with method access', Xenuti::Config

  describe 'check' do
    it 'should return true for valid report' do
      expect(report.check).to be_true
    end

    it 'should verify start time contains a Time' do
      report.scan_info.start_time = 12
      expect { report.check }.to raise_error RuntimeError
    end

    it 'should verify end time contains a Time' do
      report.scan_info.end_time = 12
      expect { report.check }.to raise_error RuntimeError
    end

    it 'should verify duration is an Float' do
      report.scan_info.duration = :a
      expect { report.check }.to raise_error RuntimeError
    end

    it 'should verify scanner_name is a String' do
      report.scan_info.scanner_name = :a
      expect { report.check }.to raise_error RuntimeError
    end

    it 'should verify scanner_version is a String' do
      report.scan_info.scanner_version = :a
      expect { report.check }.to raise_error RuntimeError
    end

    it 'should verify that all warnings are Hash' do
      report.warnings[1] = 'serious issue'
      expect { report.check }.to raise_error RuntimeError
    end
  end
end
