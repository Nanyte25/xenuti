# Copyright (C) 2014 Jan Rusnacko
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of the
# MIT license.

require 'tempfile'
require 'ruby_util/multi_write_io'

describe MultiWriteIO do
  it 'should write to multiple IO objects' do
    file1 = Tempfile.new('multi_write_io')
    file2 = Tempfile.new('multi_write_io')
    mwio = MultiWriteIO.new(file1, file2)
    mwio.write('TEST')
    mwio.close
    expect(file1.open.read).to be_eql('TEST')
    expect(file2.open.read).to be_eql('TEST')
    # Tempfiles are automatically deleted
  end
end
