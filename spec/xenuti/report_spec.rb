# Copyright (C) 2014 Jan Rusnacko
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of the
# MIT license.

require 'spec_helper'
require 'ruby_util/hash_with_method_access_shared'

describe Xenuti::Report do
  it_behaves_like 'hash with method access', Xenuti::Report.new
end
