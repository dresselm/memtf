require 'terminal-table'

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
		table = Terminal::Table.new(:headings => ['Class', 'Objects', 'Leakage', 'Impact']) do |t|
			group_analysis = Memtf::Analyzer.analyze_group(group)
			group_analysis.sort_by { |k,v| -v['impact'] }.each do |k,v|
				t << [k,v['count'],to_MB(v['size']),to_pct(v['impact'])]
			end
		end
		puts table
	end

	private

	def to_MB(bytes)
  	"%.3fMB" % [bytes]
	end

	def to_pct(num)
		"%.2f%" % [num * 100]
	end
end