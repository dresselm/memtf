module Memtf
  START_STAGE = :start
  FINISH_STAGE = :finish

  class << self
    attr_accessor :runner

    def start(options={})
      self.runner = Runner.run(START_STAGE, options)
    end

    def finish(options={})
      Runner.run(FINISH_STAGE, options.merge(:group => self.runner.group))
    ensure
      self.runner = nil
    end

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

require 'fileutils'
require 'multi_json'
require 'objspace'
