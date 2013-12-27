# Monkeypatch Array with various utilities.
module Memtf::Utilities::Array

  # Add up all array elements.
  #
  # @return [Number]
  def sum
		inject(0) { |sum, elem| sum + elem }
	end
end

# Only monkeypatch if the method has not been defined already.
unless Array.method_defined? :sum
	Array.send :include, Memtf::Utilities::Array
end
