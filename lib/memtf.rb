# A simple utility to help isolate memory leaks.  Two
# memory snapshots are compared to determine which
# classes, if any, are leaking.
module Memtf
  # Represents the starting memory snapshot
  START = :start
  # Represents the ending memory snapshot
  STOP  = :stop

  class << self
    attr_accessor :runner

    # Generate an initial memory snapshot.
    #
    # @param [Hash] options
    # @return [Runner]
    def start(options={})
      self.runner = Runner.run(START, options)
    end

    # Generate a final memory snapshot.
    #
    # @param [Hash] options
    def stop(options={})
      default_group = self.runner.group
      Runner.run(STOP, {:group => default_group}.merge(options))
    ensure
      self.runner = nil
    end

    # Generate an initial memory snapshot, execute
    # the block, then generate the final memory snapshot.
    #
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
