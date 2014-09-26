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
  let(:ignored_old) { { name: :d, 'ignore_field' => 'Old report' } }
  let(:ignored_new) { { name: :d, 'ignore_field' => 'New report' } }

  let(:new_report) do
    new_report = Xenuti::ScriptReport.new
    new_report.messages << both_warn
    new_report.messages << new_warn
    new_report.messages << ignored_new
    new_report
  end
  let(:old_report) do
    old_report = Xenuti::ScriptReport.new
    old_report[:scan_info] = { start_time: 1, revision: :a }
    old_report.messages << both_warn
    old_report.messages << old_warn
    old_report.messages << ignored_old
    old_report
  end

  describe '::diff' do
    it 'should diff correctly' do
      new_report.diff!(old_report)
      expect(new_report.new_messages).to be_eql([new_warn, ignored_new])
      expect(new_report.fixed_messages).to be_eql([old_warn, ignored_old])
      expect([:a, :b].include? new_report.messages[0][:name]).to be_true
      expect([:a, :b].include? new_report.messages[1][:name]).to be_true
    end

    it 'should ignore fields when specified as array' do
      new_report.diff!(old_report, [:foo, 'ignore_field', :bar])

      # new_messages contain new_warn
      expect(new_report.new_messages.size).to be_eql(1)
      expect(new_report.new_messages.first[:name]).to be_eql(:b)

      # fixed_messages containt old_warn
      expect(new_report.fixed_messages.size).to be_eql(1)
      expect(new_report.fixed_messages.first[:name]).to be_eql(:c)

      expect([:a, :b].include? new_report.messages[0][:name]).to be_true
      expect([:a, :b].include? new_report.messages[1][:name]).to be_true
    end

    it 'should ignore field when specified as string' do
      new_report.diff!(old_report, 'ignore_field')

      # new_messages contain new_warn
      expect(new_report.new_messages.size).to be_eql(1)
      expect(new_report.new_messages.first[:name]).to be_eql(:b)

      # fixed_messages containt old_warn
      expect(new_report.fixed_messages.size).to be_eql(1)
      expect(new_report.fixed_messages.first[:name]).to be_eql(:c)

      expect([:a, :b].include? new_report.messages[0][:name]).to be_true
      expect([:a, :b].include? new_report.messages[1][:name]).to be_true
    end

    it 'should not modify old report passed as argument' do
      new_report.diff!(old_report)
      expect { old_report.new_messages }.to raise_error NoMethodError
      expect { old_report.fixed_messages }.to raise_error NoMethodError
      new_report.messages << 'foo'
      expect(old_report.messages.size).to be_eql(3)
    end
  end
end
