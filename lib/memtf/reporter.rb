require 'colored'

class Memtf::Reporter

	attr_reader :group, :options

	def self.report(group)
		new(group).report
	end

	def initialize(group, options={})
		@group = group
		@options = options
	end

	def report
		group_analysis = Memtf::Analyzer.analyze_group(group)

		group_analysis.each do |k,v|
			puts [k,v].join(', ')
		end
	end
end