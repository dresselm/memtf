module Memtf
  # Represents the start of a run
  START  = :start
  # Represents the end of a run
  FINISH = :finish

  class << self
    attr_accessor :runner

    # @param [Hash] options
    # @return [Runner]
    def start(options={})
      self.runner = Runner.run(START, options)
    end

    # @param [Hash] options
    def finish(options={})
      default_group = self.runner.group
      Runner.run(FINISH, {:group => default_group}.merge(options))
    ensure
      self.runner = nil
    end

    # @param [Hash] options
    def around(options={}, &block)
      start(options)
      block.call if block_given?
      finish(options)
    end
  end
end

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__)))

require 'memtf/utilities'
require 'memtf/analyzer'
require 'memtf/reporter'
require 'memtf/persistance'
require 'memtf/runner'
require 'memtf/version'
