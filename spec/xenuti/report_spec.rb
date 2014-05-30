# Copyright (C) 2014 Jan Rusnacko
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of the
# MIT license.

require 'spec_helper'
require 'ruby_util/hash_with_method_access_shared'
require 'tempfile'
require 'fileutils'
require 'ruby_util/string'

describe Xenuti::Report do
  let(:report) { Xenuti::Report.new }
  let(:tmp) do
    tmp = Dir.mktmpdir
    at_exit do
      FileUtils.rm_rf(tmp)
    end
    tmp
  end

  # This does not work, as constructor initializes the hash
  # It is fine though, since method access is tested on other places anyway
  # it_behaves_like 'hash with method access', Xenuti::Report.new

  describe '::latest_report' do
    it 'should return the latest report' do
      Dir.mkdir tmp + '/reports'
      newer = '2014-05-30T15:38:04+02:00'
      older = '2014-05-30T15:37:04+02:00'

      Dir.mkdir tmp + '/reports/' + newer
      File.open(tmp + '/reports/' + newer + '/report.yml', 'w+') do |file|
        file.write <<-EOF.unindent
        --- !ruby/hash:Xenuti::Report
        :scan_info:
          :version: 0.0.1
          :start_time: 2014-05-30 15:37:04.001 +02:00
        :scanner_reports: []
        :config: {}
        :name: :new
        EOF
      end

      Dir.mkdir tmp + '/reports/' + older
      File.open(tmp + '/reports/' + older + '/report.yml', 'w+') do |file|
        file.write <<-EOF.unindent
        --- !ruby/hash:Xenuti::Report
        :scan_info:
          :version: 0.0.1
          :start_time: 2014-05-27 15:37:04.002 +02:00
        :scanner_reports: []
        :config: {}
        :name: :old
        EOF
      end

      config = Xenuti::Config.from_hash(general: { tmpdir: tmp })
      expect(Xenuti::Report.latest_report(config).name).to be_eql(:new)
    end

    it 'should return nil when directory does not contain any report yet' do
      config = Xenuti::Config.from_hash(general: { tmpdir: FIXTURES })
      expect(Xenuti::Report.latest_report(config)).to be_eql(nil)
    end
  end

  describe '#reports_dir' do
    it 'output should be the same across multiple calls' do
      config = Xenuti::Config.from_hash(general: { tmpdir: tmp })
      reports_dir1 = report.reports_dir(config)
      reports_dir2 = report.reports_dir(config)
      expect(reports_dir1).to be_eql(reports_dir2)
    end
  end

  describe '#save and ::load' do
    it 'report should be identical after saving and loading again' do
      config = Xenuti::Config.from_hash(general: { tmpdir: tmp })
      report[:config] = { general: { tmpdir: tmp } }
      report.scan_info.start_time = Time.now
      report.save(config)
      latest = Xenuti::Report.latest_report(config)
      expect(latest).to be_eql(report)
    end
  end

  describe '#duration' do
    it 'should compute duration correctly' do
      report.scan_info.start_time = Time.new(2008, 6, 21, 13, 30, 1.1)
      report.scan_info.end_time = Time.new(2008, 6, 21, 13, 30, 2.3)
      expect(report.duration).to be_eql(1.2)
    end
  end

  describe '#diff!' do
    it 'should diff with older report correctly' do
      # fail 'Implement this test'
    end

    it 'should not do anything when diffed with nil' do

    end
  end
end
