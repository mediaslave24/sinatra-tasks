require 'pry'
require './ruby/griddable.rb'
grid = Marshal.load(IO.read("./grid-bulgaria.marshal"))

binding.pry
