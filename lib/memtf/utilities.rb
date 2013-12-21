module Memtf::Utilities
end

require 'memtf/utilities/array'
Array.send :include, Memtf::Utilities::Array
