require 'spec_helper'

describe Memtf::Analyzer do
  describe '.analyze' do
    let(:options)  { {} }

    it 'should create a new Analyzer' do
      mock_analyzer = mock(described_class)
      mock_analyzer.stub(:analyze)
      described_class.should_receive(:new).with(options).and_return(mock_analyzer)

      described_class.analyze(options)
    end

    it 'should delegate to analyze' do
      mock_analyzer = mock(described_class)
      described_class.stub(:new).with(options).and_return(mock_analyzer)
      mock_analyzer.should_receive(:analyze).and_return({})

      described_class.analyze(options)
    end
  end

  describe '.analyze_group' do
    let(:start_data) {
      {
       'Array'   => {'count' => 1, 'size' => 10},
       'Hash'    => {'count' => 2, 'size' => 5},
       'Fixnum'  => {'count' => 2, 'size' => 10},
       'Others*' => {'count' => 3, 'size' => 4}
      }
    }
    let(:end_data) {
      {
       'Array'   => {'count' => 3, 'size' => 50},
       'Hash'    => {'count' => 4, 'size' => 20},
       'Fixnum'  => {'count' => 8, 'size' => 20},
       'Others*' => {'count' => 6, 'size' => 10}
      }
    }
    let(:group) { 'test_group' }

    it 'should load the start data' do
      Memtf::Persistance.should_receive(:load).with(Memtf::START,group).and_return(start_data)
      Memtf::Persistance.stub(:load).with(Memtf::STOP,group).and_return(end_data)

      described_class.analyze_group(group)
    end

    it 'should load the end data' do
      Memtf::Persistance.stub(:load).with(Memtf::START,group).and_return(start_data)
      Memtf::Persistance.should_receive(:load).with(Memtf::STOP,group).and_return(end_data)

      described_class.analyze_group(group)
    end

    it 'should compare the start and end object counts' do
      Memtf::Persistance.stub(:load).with(Memtf::START,group).and_return(start_data)
      Memtf::Persistance.stub(:load).with(Memtf::STOP,group).and_return(end_data)

      output       = described_class.analyze_group(group)
      count_deltas = output.values.map { |o| o['count_delta']}
      count_deltas.should_not be_empty
      count_deltas.size.should == 4
      count_deltas.should == [(3-1),(4-2),(8-2),(6-3)]
    end

    it 'should compare the start and end memory sizes' do
      Memtf::Persistance.stub(:load).with(Memtf::START,group).and_return(start_data)
      Memtf::Persistance.stub(:load).with(Memtf::STOP,group).and_return(end_data)

      output      = described_class.analyze_group(group)
      size_deltas = output.values.map { |o| o['size_delta']}
      size_deltas.should_not be_empty
      size_deltas.size.should == 4
      size_deltas.should == [(50-10),(20-5),(20-10),(10-4)]
    end

    it 'should generate an impact value' do
      Memtf::Persistance.stub(:load).with(Memtf::START,group).and_return(start_data)
      Memtf::Persistance.stub(:load).with(Memtf::STOP,group).and_return(end_data)

      output  = described_class.analyze_group(group)
      impacts = output.values.map { |o| o['impact'] }
      impacts.should_not be_empty
      impacts.size.should == 4
      # The impact is calculates as memory size of class
      # compared to the total memory size
      impacts.should == [0.5,0.2,0.2,0.1]
    end
  end

  describe '#analyze' do
    it 'should try to garbage collect'
    it 'should calculate the total memory allocated to each class'
    it 'should isolate classes that exceed a given memory threshold'
    it 'should generate an aggregated Others* row'
    it 'should translate the results into a simple hash'
  end
end
