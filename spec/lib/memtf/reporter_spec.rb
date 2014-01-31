require 'spec_helper'

describe Memtf::Reporter do

  let(:group)    { 'test_group' }
  let(:reporter) { described_class.new(group) }

  describe '.report' do

    it 'should initialize a new reporter' do
      reporter.stub(:report)
      described_class.should_receive(:new).with(group).and_return(reporter)

      described_class.report(group)
    end

    it 'should delegate to report' do
      described_class.stub(:new).and_return(reporter)
      reporter.should_receive(:report)

      described_class.report(group)
    end
  end

  describe '#report' do
    let(:analysis) {
      {
        'key1' => {'size' => 2,  'count' => 1000, 'impact' => 0.02},
        'key2' => {'size' => 78, 'count' => 600,  'impact' => 0.78},
        'key3' => {'size' => 20, 'count' => 50,   'impact' => 0.20}
      }
    }

    it 'should delegate to Memtf::Analyzer.analyze_group' do
      Memtf::Analyzer.should_receive(:analyze_group).with(group).and_return(analysis)

      reporter.report
    end

    it 'should sort the analysis by impact' do
      Memtf::Analyzer.stub(:analyze_group).with(group).and_return(analysis)

      table = reporter.report
      table.rows.map {|r| r.cells.first.value }.should == ['key2', 'key3', 'key1']
    end

    it 'should print headers' do
      Memtf::Analyzer.stub(:analyze_group).with(group).and_return(analysis)

      table = reporter.report
      table.headings.cells.map(&:value).should == ["Class", "Impact", "LeakageSize", "NumObjects"]
    end

    it 'should convert impact to a human readable percentage' do
      Memtf::Analyzer.stub(:analyze_group).with(group).and_return(analysis)

      table = reporter.report
      table.rows.map {|r| r.cells[1].value }.should == ['78.00%','20.00%','2.00%']
    end

    it 'should convert sizes to human readable MB' do
      Memtf::Analyzer.stub(:analyze_group).with(group).and_return(analysis)

      table = reporter.report
      table.rows.map {|r| r.cells[2].value }.should == ['78.000MB','20.000MB','2.000MB']
    end

  end

end
