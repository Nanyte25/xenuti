# Copyright (C) 2014 Jan Rusnacko
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of the
# MIT license.

# So here`s how we test this: by requiring alpha_helper, we copy fixtures/alpha
# to temporary directory and initialize it to be a Git repo. We use this repo
# in tests as a repo to be cloned, and since alpha is a Rails 3 app, we can run
# analysis on it.
require 'spec_helper'
require 'tempfile'
require 'fileutils'

describe 'Integration Tests' do

  context 'Custom backend, custom script, diff report' do
    before(:all) do
      @workdir = Dir.mktmpdir
      @config = Tempfile.new('config')

      # create config
      File.open(@config, 'w+') do |file|
        file.write <<-EOF.unindent
          ---
          general:  
            name: integration
            workdir: #{@workdir}
            scriptdir: #{CUSTOM_SCRIPTDIR}
            backenddir: #{CUSTOM_BACKENDDIR}
            quiet: true

          content_update:
            backend: dummy_backend
            args:

          process:
            dummy_script:
              args:
              diff: true

          report:
            send_mail: false
        EOF
      end

      # run xenuti twice
      %x(#{XENUTI_P} run #{@config.path} --trace)
      %x(#{XENUTI_P} run #{@config.path} --trace)

      # find report and log files
      # for some reason newer one is always listed first
      report_file = Dir.glob(File.join(@workdir,"**/report.yml"))[0]
      logfile = Dir.glob(File.join(@workdir,"**/xenuti.log"))[0]
      @report = YAML.load(IO.read(report_file), safe: false)
      @logs = IO.read logfile
    end

    after(:all) do
      FileUtils.rm_rf(@workdir)
      FileUtils.rm_rf(@config)
    end

    it 'report should have correct scan_info header' do
      scan_info = @report['scan_info']
      expect(scan_info['version']).to be_a(String)
      expect(scan_info['start_time']).to be_a(Time)
      expect(scan_info['end_time']).to be_a(Time)
    end

    it 'script report should have correct scan_info header' do
      scan_info = @report['script_reports'].first['scan_info']
      expect(scan_info['script_name']).to eq('dummy_script')
      expect(scan_info['start_time']).to be_a(Time)
      expect(scan_info['end_time']).to be_a(Time)
      expect(scan_info['version']).to be_a(String)
      expect(scan_info['relpath']).to eq('')
      expect(scan_info['mode']).to eq('diff results')
      expect(scan_info['args']).to be_nil
    end

    it 'script report should contain no reference to old_report' do
      expect(@report['script_reports'].first['old_report']).to_not eq({})
    end

    it 'script report should contain messages' do
      messages = @report['script_reports'].first['messages']
      expect(messages).to be_a(Array)
      expect(messages.size).to eq(1)  # because dummy_script returns just one
    end

    it 'script report should contain some fixed messages' do
      messages = @report['script_reports'].first['fixed_messages']
      expect(messages).to be_a(Array)
      expect(messages.size).to eq(1)  # because dummy_script returns just one
    end

    it 'script report should contain some new messages' do
      messages = @report['script_reports'].first['new_messages']
      expect(messages).to be_a(Array)
      expect(messages.size).to eq(1)  # because dummy_script returns just one
    end

    it 'logfile should contain logs in correct format' do
      # TODO
    end
  end



  # Run signle custom backend with multiple scripts (one git, one custom),
  # go for diff report
  context 'Single backend, multiple scripts, diff report' do


  end

  context 'Multiple backends, multiple scripts, with sorting' do

  end

  context 'Multiple backends with relative paths, multiple scripts' do

  end
end