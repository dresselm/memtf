class Memtf::Runner
	attr_reader :group, :options, :report

  # @param [String] stage
  # @param [Hash] options
	def self.run(stage, options={})
		new(options).run(stage)
	end

	def initialize(options={})
		@group   = options.delete(:group) || Time.now.to_i
		@options = options
	end

  # @param [String] stage
	def run(stage)
		analysis = Memtf::Analyzer.analyze(options)
    Memtf::Persistance.save(stage, group, analysis)
    analysis = nil

    if stage == Memtf::FINISH
      @report = Memtf::Reporter.report(group)
      puts @report
    end

		self
	end
end