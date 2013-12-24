require 'spec_helper'

describe Memtf do
  let(:options) { {} }

  describe '.start' do
    it 'should delegate to Memtf::Runner' do
      Memtf::Runner.should_receive(:run).with(Memtf::START, options)

      Memtf.start(options)
    end

    it 'should set the runner variable' do
      Memtf.runner.should be_nil

      expected_runner = Memtf.start(options)

      Memtf.runner.should_not be_nil
      Memtf.runner.should == expected_runner
    end
  end

  describe '.stop' do
    it 'should delegate to Memtf::Runner' do
      Memtf::Runner.should_receive(:run).with(Memtf::STOP, hash_including(:group))

      Memtf.stop(options)
    end

    it 'should clear the runner variable' do
      runner = Memtf.start(options)
      Memtf.runner.should_not be_nil

      Memtf.stop(options)
      Memtf.runner.should be_nil
    end
  end

  describe '.around' do
    it 'should delegate to start' do
      Memtf.should_receive(:start).with(options)
      Memtf.stub(:stop)

      Memtf.around(options) { a = 1 + 2 }
    end

    it 'should delegate to finish' do
      Memtf.should_receive(:stop).with(options)

      Memtf.around(options) { a = 1 + 2 }
    end

    it 'should call the given block' do
      Memtf.stub(:stop)
      lambda = lambda { a = 1 + 2 }
      lambda.should_receive(:call)

      Memtf.around(options,&lambda)
    end
  end
end