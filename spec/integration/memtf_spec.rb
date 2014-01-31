require 'spec_helper'

describe 'Integration tests' do
  class LeakyArray < Array; end
  class Leak < Struct.new(:id, :name); end
  class LeakyHarness < Struct.new(:leaker)
    def leak
      25000.times do |index|
        leaker << Leak.new(index, "Name: #{index}")
      end
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

  before(:each) do
    @leaky_array = LeakyArray.new
    @harness     = LeakyHarness.new(@leaky_array)
  end

  it 'should expose the memory leak' do
    runner  = Memtf.around do
      @harness.leak
    end

    leaker_class_names(runner).should include('LeakyArray')
  end

  it 'should rollup minor leaks into Other*' do
    runner  = Memtf.around do
      @harness.leak
    end

    leaker_class_names(runner).should include('Others*')
  end

  context 'when the memory leak is fixed' do
    it 'should not display the leak' do
      runner = Memtf.around do
        @harness.leak

        @harness.leaker.each { |leak| leak = nil}
        @harness.leaker = nil
        @harness        = nil
        @leaky_array    = nil
      end

      leaker_class_names(runner).should_not include('LeakyArray')
    end
  end
end
