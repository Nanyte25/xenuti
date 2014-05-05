# Copyright (C) 2014 Jan Rusnacko
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of the
# MIT license.

require 'xenuti'

RSpec.configure do |config|
  config.color_enabled = true
  config.formatter = :documentation
end

FIXTURES_DIR = File.expand_path('../fixtures', __FILE__)
