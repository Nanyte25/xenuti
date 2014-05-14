# Copyright (C) 2014 Jan Rusnacko
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of the
# MIT license.

shared_examples 'static_analyzer' do |analyzer_klass|
  let(:config) { Xenuti::Config.from_yaml(File.new(CONFIG_FILEPATH).read) }
  let(:analyzer) { analyzer_klass.new(config) }

  context 'loaded?' do
    it 'returns false when queried class is not loaded' do
      expect(analyzer.loaded?('AbsolutelyDoesNotExists')).to be_false
    end

    it 'returns true when queried class is loaded' do
      expect(analyzer.loaded?('Object')).to be_true
    end
  end

  context 'enabled?' do
    it 'can be enabled' do
      config[analyzer.name][:enabled] = true
      expect(analyzer.enabled?).to be_true
    end

    it 'can be disabled' do
      config[analyzer.name][:enabled] = false
      expect(analyzer.enabled?).to be_false
    end
  end

  context 'check_config' do
    it 'should fail if source is not present in config' do
      config.general.source = nil
      expect do
        analyzer.check_config
      end.to raise_error RuntimeError
      config.general = nil
      expect do
        analyzer.check_config
      end.to raise_error NoMethodError
    end

    it 'should pass when source is present in config' do
      expect(analyzer.check_config).to be_true
    end
  end
end
