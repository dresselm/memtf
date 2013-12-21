require 'memtf/version'
require 'memtf/analyzer'
require 'memtf/reporter'
require 'memtf/persistor'
require 'memtf/runner'

require 'fileutils'
require 'multi_json'
require 'objspace'

module Memtf
  START_STAGE = :start
  FINISH_STAGE = :finish

  def self.start(options={})
    @runner = Runner.run(START_STAGE, options)
  end

  def self.finish(options={})
    Runner.run(FINISH_STAGE, options.merge(:group => @runner.group))
  end

  def self.around(options={}, &block)
    start(options)
    block.call if block_given?
    finish(options)
  end

end
