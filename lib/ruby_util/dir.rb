# Copyright (C) 2014 Jan Rusnacko
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of the
# MIT license.

class Dir
  # TODO: add diff to dependencies

  def eql?(dir)
    self.class.compare(self, dir)
  end

  def self.compare(dir1, dir2)
    dir1 = dir1.to_path if dir1.is_a? Dir
    dir2 = dir2.to_path if dir2.is_a? Dir
    %x(diff #{dir1} #{dir2})
    $? == 0
  end

  # rubocop:disable RescueException
  def self.jumpd(dir, &block)
    old_pwd = Dir.pwd
    begin
      Dir.chdir dir
      block.call
    rescue Exception => e
      Dir.chdir old_pwd
      raise e
    end
  end
  # rubocop:enable RescueException
end
