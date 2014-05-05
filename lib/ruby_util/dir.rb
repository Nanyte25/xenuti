# Copyright (C) 2014 Jan Rusnacko
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of the
# MIT license.

class Dir
  def eql?(dir)
    # Todo: add to requirements
    %x{diff #{self.to_path} #{dir.to_path}}
    return $? == 0
  end
end