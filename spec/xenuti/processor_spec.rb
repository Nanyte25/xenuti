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

  context '::content_update' do
    it 'should check out the code from repo to source directory' do
      backend_paths = Xenuti::Processor.map_names_to_paths(config)['backends']
      out = Xenuti::Processor.content_update(config, backend_paths)
      expect(Dir.compare(ALPHA_REPO, out['source'])).to be true
    end
  end

  context '::map_script_names_to_paths' do
    let(:map) { Xenuti::Processor.map_names_to_paths(config) }

    it 'should return a hash' do
      expect(map).to be_a Hash
    end

    it 'should discover scripts bundled with Xenuti' do
      expect(map['scripts']['brakeman']).not_to be nil
    end

    it 'should discover scripts in custom scripts directory' do
      expect(map['scripts']['dummy_check']).not_to be nil
    end
  end

  context '#run' do
    it 'should return full report when run in full report mode' do
      processor.config['general']['name'] = 'Alpha'
      report = processor.run
      expect(report).to be_a Xenuti::Report
      expect(report[:script_reports].first.diffed?).to be false
    end

    it 'should return report with just new messages when run in diff mode' do
      processor.config['process']['brakeman']['args'] = nil
      processor.config['process']['brakeman']['diff'] = true

      # Uncomment secret token - this should cause Brakeman to report Session
      # Setting warning
      Dir.jumpd(ALPHA_REPO) do
        %x(sed -i 's/#Alph/Alph/' config/initializers/secret_token.rb)
        %x(git commit -a -m "Uncommenting session secret - will cause warning")
      end

      # Run once - older report will be reused from the above testcase
      report = processor.run
      expect(report).to be_a Xenuti::Report
      expect(report['script_reports'].first.diffed?).to be true
      expect(report['script_reports'].first.new_messages.size).to be_eql(1)
      expect(report['script_reports'].first.new_messages[0]['warning_type']).to \
        be_eql('Session Setting')
      expect(report['script_reports'].first.fixed_messages.size).to be_eql(0)
    end

    it 'should fall back to full report mode when older report is not avail' do
      processor.config['process']['brakeman']['args'] = nil
      processor.config['process']['brakeman']['diff'] = true

      # Remove old reports, so diff can`t work
      FileUtils.rm_rf(ALPHA_WORKDIR + '/reports')
      report = processor.run
      expect(report).to be_a Xenuti::Report
      expect(report['script_reports'].first.diffed?).to be false
      expect(report['scanner_reports']).to be nil
    end
  end
end
