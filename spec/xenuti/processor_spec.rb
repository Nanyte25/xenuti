# Copyright (C) 2014 Jan Rusnacko
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of the
# MIT license.

# So here`s how we test this: by requiring alpha_helper, we copy fixtures/alpha
# to temporary directory and initialize it to be a Git repo. We use this repo
# in tests as a repo to be cloned, and since alpha is a Rails 3 app, we can run
# analysis on it.
require 'helpers/alpha_helper'
require 'fileutils'

describe Xenuti::Processor do
  let(:config) do
    yaml =  File.new(FIXTURES + '/alpha_config.yml').read
    Xenuti::Config.from_yaml(yaml)
  end
  let(:processor) { Xenuti::Processor.new(config) }

  context '#checkout_code' do
    it 'should check out the code from repo to source directory' do
      processor.checkout_code(Xenuti::Report.new)
      expect(Dir.compare(ALPHA_REPO, config.general.source)).to be_true
    end
  end

  context '#run' do
    it 'should return full report when run in full report mode' do
      processor.config.brakeman.enabled = true
      report = processor.run
      expect(report).to be_a Xenuti::Report
      expect(report.diffed?).to be_false
    end

    it 'should return report with just new warnings when run in diff mode' do
      processor.config.brakeman.enabled = true
      processor.config.general.diff = true

      # Uncomment secret token - this should cause Brakeman to report Session
      # Setting warning
      Dir.jumpd(ALPHA_REPO) do
        %x(sed -i 's/#Alph/Alph/' config/initializers/secret_token.rb)
        %x(git commit -a -m "Uncommenting session secret - will cause warning")
      end

      # Run once - older report will be reused from the above testcase
      report = processor.run
      expect(report).to be_a Xenuti::Report
      expect(report.diffed?).to be_true
      expect(report.scanner_reports[0].new_warnings.size).to be_eql(1)
      expect(report.scanner_reports[0].new_warnings[0].warning_type).to \
        be_eql('Session Setting')
      expect(report.scanner_reports[0].fixed_warnings.size).to be_eql(0)
    end

    it 'should fall back to full report mode when older report is not avail' do
      processor.config.brakeman.enabled = true
      processor.config.general.diff = true

      # Remove old reports, so diff can`t work
      FileUtils.rm_rf(ALPHA_WORKDIR + '/reports')
      report = processor.run
      expect(report).to be_a Xenuti::Report
      expect(report.diffed?).to be_false
      expect { report.scanner_reports[0].new_warnings }.to raise_error
    end
  end
end
