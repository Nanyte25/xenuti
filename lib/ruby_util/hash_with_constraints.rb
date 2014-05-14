# Copyright (C) 2014 Jan Rusnacko
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of the
# MIT license.

require 'rspec/expectations'
# TODO: doc
module HashWithConstraints
  include RSpec::Expectations

  # rubocop:disable TrivialAccessors
  def constraints(&constraints)
    @constraints = constraints
  end
  # rubocop:enable TrivialAccessors

  # rubocop:disable RedundantBegin
  def check
    begin
      @constraints.call(self)
    rescue RSpec::Expectations::ExpectationNotMetError
      raise 'One of the constraints is not met.'
    end
  end
  # rubocop:enable RedundantBegin
end
