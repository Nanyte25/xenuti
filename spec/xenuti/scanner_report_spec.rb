# Copyright (C) 2014 Jan Rusnacko
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of the
# MIT license.

require 'spec_helper'

describe Xenuti::ScannerReport do
  it_behaves_like 'hash with method access', Xenuti::ScannerReport.new

  let(:both_warn) { Xenuti::Warning.from_hash(name: :a, msg: 'both') }
  let(:new_warn) { Xenuti::Warning.from_hash(name: :b, msg: 'New warning') }
  let(:old_warn) { Xenuti::Warning.from_hash(name: :c, msg: 'Fixed warning') }
  let(:new_report) do
    new_report = Xenuti::ScannerReport.new
    new_report.warnings << both_warn
    new_report.warnings << new_warn
    new_report
  end
  let(:old_report) do
    old_report = Xenuti::ScannerReport.new
    old_report.warnings << both_warn
    old_report.warnings << old_warn
    old_report
  end

  describe '::diff' do
    it 'should diff correctly' do
      diffed = Xenuti::ScannerReport.diff(old_report, new_report)
      expect(diffed.new_warnings).to be_eql([new_warn])
      expect(diffed.fixed_warnings).to be_eql([old_warn])
      expect([:a, :b].include? diffed.warnings[0][:name]).to be_true
      expect([:a, :b].include? diffed.warnings[1][:name]).to be_true
    end

    it 'should not modify reports passed as argument' do
      diffed = Xenuti::ScannerReport.diff(old_report, new_report)
      expect { new_report.new_warnings }.to raise_error NoMethodError
      expect { old_report.new_warnings }.to raise_error NoMethodError
      expect { new_report.fixed_warnings }.to raise_error NoMethodError
      expect { old_report.fixed_warnings }.to raise_error NoMethodError
      diffed.warnings << 'foo'
      expect(new_report.warnings.size).to be_eql(2)
      expect(old_report.warnings.size).to be_eql(2)
    end
  end
end
