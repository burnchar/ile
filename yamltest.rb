#!/usr/bin/env Ruby
class Z
  attr_reader :aaa, :xxx
  def initialize b
    @aaa = b
    @xxx = B.new
  end
end

class B
  attr_reader :name
  def initialize
    @name = "Haha"
  end
end
