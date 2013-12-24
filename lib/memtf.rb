module Memtf
  # Represents the starting
  START = :start
  # Represents the end of a run
  STOP  = :stop

  class << self
    attr_accessor :runner

    # @param [Hash] options
    # @return [Runner]
    def start(options={})
      self.runner = Runner.run(START, options)
    end

    # @param [Hash] options
    def stop(options={})
      default_group = self.runner.group
      Runner.run(STOP, {:group => default_group}.merge(options))
    ensure
      self.runner = nil
    end

    # @param [Hash] options
    def around(options={}, &block)
      start(options)
      block.call if block_given?
      stop(options)
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
