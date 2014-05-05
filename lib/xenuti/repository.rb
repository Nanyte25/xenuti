# Copyright (C) 2014 Jan Rusnacko
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of the
# MIT license.

class Xenuti::Repository
  def self.fetch_source(config, destination)
    if Dir.entries(destination).size == 2   # destination dir is empty
      %x{git clone #{config.general.repo} #{destination} 2>&1}
    else
      %x{pushd #{destination}; git pull 2>&1; popd}
    end
  end
end