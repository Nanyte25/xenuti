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

describe Xenuti::Processor do
  let(:config) do
    yaml =  File.new(FIXTURES + '/alpha_config.yml').read
    Xenuti::Config.from_yaml(yaml)
  end
  let(:processor) { Xenuti::Processor.new(config) }

  context 'checkout_code' do
    it 'should check out the code from repo to source directory' do
      processor.checkout_code
      expect(Dir.compare(ALPHA_REPO, config.general.source)).to be_true
    end
  end
end
