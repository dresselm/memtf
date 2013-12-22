require 'spec_helper'

describe 'Integration tests' do
  class Leak < Struct.new(:id); end
  class LeakyHarness < Struct.new(:leaker)
    def leak
      50000.times do |index|
        leaker << Leak.new(index)
      end
    end
  end

  def first_cell_value(runner)
    report     = runner.report
    first_row  = report.rows.first
    first_cell = first_row.cells.first
    first_cell.value
  end

  it 'should expose the memory leak' do
    arr = []
    runner = Memtf.around do
      LeakyHarness.new(arr).leak
    end

    first_cell_value(runner).should == 'Array'
  end

  context 'when the memory leak is fixed' do
    it 'should not expose a memory leak' do
      runner = Memtf.around do
        arr = []
        LeakyHarness.new(arr).leak
      end

      first_cell_value(runner).should_not == 'Array'
    end
  end

end