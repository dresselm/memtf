module Memtf::Utilities::Array
  # @return [Number]
  def sum
		inject(0) { |sum, elem| sum + elem }
	end
end

unless Array.method_defined? :sum
	Array.send :include, Memtf::Utilities::Array
end