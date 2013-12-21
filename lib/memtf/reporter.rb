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
		start_analysis = Memtf::Persistor.load(Memtf::START_STAGE, group)
		end_analysis   = Memtf::Persistor.load(Memtf::FINISH_STAGE, group)

		payload = Memtf::Analyzer.compare(start_analysis, end_analysis)

	end
end