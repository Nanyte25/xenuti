# Copyright (C) 2014 Jan Rusnacko
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of the
# MIT license.

require 'spec_helper'

describe Xenuti::ScriptReport do
  it_behaves_like 'hash with method access', Xenuti::ScriptReport.new

  let(:both_warn) { { name: :a, msg: 'both' } }
  let(:new_warn) { { name: :b, msg: 'New warning' } }
  let(:old_warn) { { name: :c, msg: 'Fixed warning' } }
  let(:new_report) do
    new_report = Xenuti::ScriptReport.new
    new_report.messages << both_warn
    new_report.messages << new_warn
    new_report
  end
  let(:old_report) do
    old_report = Xenuti::ScriptReport.new
    old_report[:scan_info] = { start_time: 1, revision: :a }
    old_report.messages << both_warn
    old_report.messages << old_warn
    old_report
  end

  describe '::diff' do
    it 'should diff correctly' do
      new_report.diff!(old_report)
      expect(new_report.new_messages).to be_eql([new_warn])
      expect(new_report.fixed_messages).to be_eql([old_warn])
      expect([:a, :b].include? new_report.messages[0][:name]).to be_true
      expect([:a, :b].include? new_report.messages[1][:name]).to be_true
    end

    it 'should not modify old report passed as argument' do
      new_report.diff!(old_report)
      expect { old_report.new_messages }.to raise_error NoMethodError
      expect { old_report.fixed_messages }.to raise_error NoMethodError
      new_report.messages << 'foo'
      expect(old_report.messages.size).to be_eql(2)
    end
  end
end
