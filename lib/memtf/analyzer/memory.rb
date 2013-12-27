require 'objspace'

# Encapsulate implementation of object memory tracking
class Memtf::Analyzer::Memory
  class << self
    # Iterate over each object on the heap
    def iterate(&block)
      ObjectSpace.each_object do |obj|
        block.call(obj)
      end
    end

    # Calculate the memory allocated to a given Object in bytes
    #
    # @param [Object] object
    # @return [Number]
    def size_of(object)
      ObjectSpace.memsize_of(object)
    end
  end
end
