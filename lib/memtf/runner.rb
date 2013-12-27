# Encapsulates the multiple steps required to accomplish
# Memtf analysis and reporting.
class Memtf::Runner
	attr_reader :group, :options, :report

  # Run the Memtf analysis and reporting.
  #
  # @param [String] stage
  # @param [Hash] options
	def self.run(stage, options={})
		new(options).run(stage)
	end

	def initialize(options={})
		@group   = options.delete(:group) || Time.now.to_i
		@options = options
	end

  # Run the Memtf analysis and reporting.
  #
  # @param [String] stage
  # @return [Memtf::Runner]
	def run(stage)
		analysis = Memtf::Analyzer.analyze(options)
    Memtf::Persistance.save(stage, group, analysis)
    analysis = nil

    if stage == Memtf::STOP
      @report = Memtf::Reporter.report(group)
      puts @report
    end

		self
	end
end
