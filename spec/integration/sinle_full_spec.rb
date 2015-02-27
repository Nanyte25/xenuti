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
  context 'Single backend (git), single script (brakeman), full report' do

    before(:all) do
      @repo = Dir.mktmpdir
      @workdir = Dir.mktmpdir
      @config = Tempfile.new('config')

      # copy source code for testing from alpha repo
      FileUtils.cp_r(FIXTURES + '/alpha/.', @repo)

      # Make it a cloneable git repo
      old_pwd = Dir.pwd
      Dir.chdir(@repo)
      %x(git init; git add -f *; git add .gitignore; git commit -m "Initial commit.")
      Dir.chdir(old_pwd)

      # create config
      File.open(@config, 'w+') do |file|
        file.write <<-EOF.unindent
          ---
          general:
            name: integration
            workdir: #{@workdir}
            scriptdir: 
            backenddir: 
            quiet: true

          content_update:
            backend: git
            args: --repository #{@repo}

          process:
            brakeman:
              args:
              diff: false

          report:
            send_mail: false
        EOF
      end

      # run xenuti
      %x(#{XENUTI_P} run #{@config.path} --trace)

      # find report and log files
      report_file = Dir.glob(File.join(@workdir,"**/report.yml"))[0]
      logfile = Dir.glob(File.join(@workdir,"**/xenuti.log"))[0]
      @report = YAML.load(IO.read(report_file), safe: false)
      @logs = IO.read logfile
    end

    after(:all) do
      FileUtils.rm_rf(@repo)
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
      expect(scan_info['script_name']).to eq('brakeman')
      expect(scan_info['start_time']).to be_a(Time)
      expect(scan_info['end_time']).to be_a(Time)
      expect(scan_info['version']).to be_a(String)
      expect(scan_info['relpath']).to eq('')
      expect(scan_info['mode']).to eq('full report')
      expect(scan_info['args']).to be_nil
    end

    it 'script report should contain reference to old_report' do
      expect(@report['script_reports'].first['old_report']).to eq({})
    end

    it 'script report should contain messages' do
      messages = @report['script_reports'].first['messages']
      expect(messages).to be_a(Array)
      expect(messages.size).to_not eq(0)
    end
  end
end