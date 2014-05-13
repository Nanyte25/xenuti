# Copyright (C) 2014 Jan Rusnacko
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of the
# MIT license.

require 'spec_helper'
require 'ruby_util/string'

describe 'String' do
  it 'should unindent correctly' do
    s = <<-EOF
    Line
      indented line
    EOF
    s.unindent.should be_eql("Line\n  indented line\n")
  end
end
