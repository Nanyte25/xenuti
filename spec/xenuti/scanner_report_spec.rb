# Copyright (C) 2014 Jan Rusnacko
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of the
# MIT license.

require 'spec_helper'

describe Xenuti::ScannerReport do
  it_behaves_like 'hash with method access', Xenuti::ScannerReport.new

  describe '#diff!' do
    it 'should diff! correctly' do
      new_report = Xenuti::ScannerReport.new
      old_report = Xenuti::ScannerReport.new

      both_warn = Xenuti::Warning.from_hash(name: 'CVE-1234-567', msg: 'both')
      new_warn = Xenuti::Warning.from_hash(msg: 'New warning')
      old_warn = Xenuti::Warning.from_hash(msg: 'Fixed warning')
      new_report.warnings << both_warn
      old_report.warnings << both_warn
      new_report.warnings << new_warn
      old_report.warnings << old_warn

      new_report.diff!(old_report)
      expect(new_report.new_warnings).to be_eql([new_warn])
      expect(new_report.fixed_warnings).to be_eql([old_warn])
      expect(new_report.warnings).to be_eql([both_warn, new_warn])
    end
  end
end
