require 'spec_helper'
require 'pry'
require 'csv'

describe 'Integration tests' do
  class LeakyHash < Hash; end
  class LeakyArray < Array
    def <<(other)
      push(other)
    end
  end

  # This is janky, but works for now as a simplistic check.
  # Since we are at the mercy of the GC, these specs are
  # generally going to lack any consistent output.
  def leaker_class_names(runner)
    report = runner.report
    rows   = report.rows
    rows.map { |row| row.cells.first.value }
  end

  it 'should expose the memory leak' do
    arr = LeakyArray.new
    # harness = LeakyHarness.new(arr)
    # 250000.times do |index|
      # instance_variable_set(:"@a#{index}", nil)
    # end
    runner  = Memtf.around do
      100.times do |index|
        # other_lead = index == 0 ? nil : instance_variable_get("@a#{index-1}")
        # instance_variable_set(:"@a#{index}", Leak.new(index))
        arr << LeakyHash.new(:leaky => true)
      end
      # harness.leak
    end

    all_classes = ObjectSpace.each_object(Class).map(&:class).uniq
    CSV.open('tmp.csv','w') do |csv|
      csv << ['ID','CLASS','DESCENDENTS','SIZE','INSPECT'] # 'File','Line','Method', 'Generation', 'ClassPath'
      ObjectSpace.each_object do |obj|
        class_name = obj.class
        descendents = []
        if (klass = obj.class).is_a?(Class)
          class_name  = klass.name
          descendents = all_classes.select { |clazz| clazz < klass }.join(',')
        end
        memsize    = ObjectSpace.memsize_of(obj)
        # sourcefile = ObjectSpace.allocation_sourcefile(obj)
        # linenum    = ObjectSpace.allocation_sourceline(obj)
        # methodid   = ObjectSpace.allocation_method_id(obj)
        # generation = ObjectSpace.allocation_generation(obj)
        # classpath  = ObjectSpace.allocation_class_path(obj)
        csv << [obj.object_id, class_name, descendents, memsize, obj.inspect] #, sourcefile, linenum, methodid, generation, classpath,
      end
    end

    # binding.pry

    leaker_class_names(runner).should include('Leak')
  end

  it 'should rollup minor leaks into Other*' do
    arr     = []
    harness = LeakyHarness.new(arr)
    runner  = Memtf.around do
      harness.leak
    end

    leaker_class_names(runner).should include('Others*')
  end

  context 'when the memory leak is fixed' do
    it 'should not expose a memory leak' do
      runner = Memtf.around do
        arr     = []
        harness = LeakyHarness.new(arr)
        harness.leak

        harness.leaker.each { |leak| leak = nil}
        harness.leaker = nil
        harness        = nil
        arr            = nil

        Leak::CONST_LEAK = nil

        GC.start
      end

      leaker_class_names(runner).should_not include('String')
    end
  end
end
