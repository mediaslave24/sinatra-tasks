require 'pry'
load './ruby/griddable.rb'
griddable = Marshal.load(IO.read('./griddable-bulgaria.marshal'))

binding.pry
