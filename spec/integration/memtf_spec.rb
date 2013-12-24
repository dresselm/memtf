require 'spec_helper'

describe 'Integration tests' do
  class Leak < Struct.new(:id, :name); end
  class LeakyHarness < Struct.new(:leaker)
    def leak
      25000.times do |index|
        leaker << Leak.new(index, "Name: #{index}")
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

    first_cell_value(runner).should == 'Leak'
  end

  it 'should rollup minor leaks into Other*' do
    arr = []
    runner = Memtf.around do
      LeakyHarness.new(arr).leak
    end

    report  = runner.report
    leakers = report.rows.map {|r| r.cells.first.value}
    leakers.should include('Others*')
  end

  context 'when the memory leak is fixed' do
    it 'should not expose a memory leak' do
      runner = Memtf.around do
        arr = []
        LeakyHarness.new(arr).leak
      end

      first_cell_value(runner).should_not == 'Leak'
    end
  end
end