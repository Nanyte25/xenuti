# Copyright (C) 2014 Jan Rusnacko
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of the
# MIT license.

shared_examples 'scanner' do |scanner_klass|
  let(:config) { Xenuti::Config.from_yaml(File.new(CONFIG_FILEPATH).read) }
  let(:scanner) { scanner_klass.new(config) }

  context 'enabled?' do
    it 'can be enabled' do
      config[scanner_klass.name][:enabled] = true
      expect(scanner.enabled?).to be_true
    end

    it 'can be disabled' do
      config[scanner_klass.name][:enabled] = false
      expect(scanner.enabled?).to be_false
    end
  end
end
