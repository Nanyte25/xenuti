# Copyright (C) 2014 Jan Rusnacko
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of the
# MIT license.

require 'simplecov'
SimpleCov.start

require 'xenuti'

RSpec.configure do |config|
  config.color_enabled = true
  config.formatter = :documentation
end

FIXTURES = File.expand_path('../fixtures', __FILE__)
CONFIG_FILEPATH = File.join(FIXTURES, '/config.yml')

CUSTOM_SCRIPTDIR = File.join(FIXTURES, 'custom_scripts')
CUSTOM_BACKENDDIR = File.join(FIXTURES, 'custom_backends')

$log = Logger.new(File.open(File::NULL, 'w'))
