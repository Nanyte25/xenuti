# Copyright (C) 2014 Jan Rusnacko
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of the
# MIT license.

module AttributeAccessors
  def define_attr_reader(object, attribute)
    object.instance_eval("def #{attribute}; @#{attribute}; end")
  end

  def define_attr_writer(object, attribute)
    object.instance_eval("def #{attribute}=(val); @#{attribute}=val; end")
  end
end