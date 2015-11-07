require_relative './simulator.rb'
require_relative './custom_reader.rb'

Simulator.new(CustomReader.new).start
