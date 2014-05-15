# Copyright (C) 2014 Jan Rusnacko
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of the
# MIT license.

# TODO: doc
module HashWithConstraints
  # rubocop:disable TrivialAccessors
  def constraints(&constraints)
    @constraints ||= []
    @constraints << constraints
  end
  # rubocop:enable TrivialAccessors

  def check
    @constraints.each do |c|
      instance_exec(self, &c)
    end
    true
  end

  def verify(&block)
    instance_exec(self, &block)
  end
end
