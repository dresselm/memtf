require 'spec_helper'

describe Memtf::Analyzer do
  let(:options)   { {} }

  describe '.analyze' do
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
    class StubbedMemoryTracker
      STRING1 = 'some_string'
      STRING2 = 'some_other_string'
      ARRAY1  = [1,2,3,4,5,6]
      HASH1   = {'foo' => 'bar'}

      def self.iterate(&block)
        [STRING1, STRING2, ARRAY1, HASH1].each do |obj|
          block.call(obj)
        end
      end

      def self.size_of(obj)
        case obj
        when STRING1 then convert_to_mb(10)
        when STRING2 then convert_to_mb(20)
        when ARRAY1  then convert_to_mb(90)
        when HASH1   then convert_to_mb(0.005)
        else
          0
        end
      end

      def self.convert_to_mb(integer)
        integer * 1024**2
      end
    end

    let(:options)  {
      {
        :memory_tracker => StubbedMemoryTracker,
        :threshold      => 0.05
      }
    }
    let(:analyzer) { described_class.new(options) }

    it 'should try to initiate garbage collection' do
      GC.should_receive(:start)

      analyzer.analyze
    end

    it 'should calculate the total memory allocated to each class' do
      analysis = analyzer.analyze

      analysis.should_not be_nil
      analysis['Array'][:size].should  == 90.0
      analysis['String'][:size].should == 20.0 + 10.0
    end

    it 'should calculate the number of objects of each class in memory' do
      analysis = analyzer.analyze

      analysis.should_not be_nil
      analysis['Array'][:count].should  == 1
      analysis['String'][:count].should == 2
    end

    it 'should isolate classes that exceed a given memory threshold' do
      analysis = analyzer.analyze

      analysis.should_not be_nil
      analysis['Hash'].should be_nil # doesn't meet threshold
    end

    it 'should generate an aggregated Others* row' do
      analysis = analyzer.analyze

      analysis.should_not be_nil
      analysis['Others*'][:size].should == 0.005
      analysis['Others*'][:count].should == 1
    end
  end
end
