class Memtf::Runner
	attr_reader :group, :options

	def self.run(stage, options={})
		new(options).run(stage)
	end

	def initialize(options={})
		@group = options.delete(:group) || Time.now.to_i
		@options = options
	end

	def run(stage)
		analysis = Memtf::Analyzer.analyze(options)
    Memtf::Persistor.persist(stage, group, analysis)
    analysis = nil

    puts Memtf::Reporter.report(group) if stage == Memtf::FINISH_STAGE

		self
	end
end