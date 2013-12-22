require 'spec_helper'

describe Memtf do
  let(:options) { {} }

  describe '.start' do
    it 'should delegate to Memtf::Runner' do
      Memtf::Runner.should_receive(:run).with(Memtf::START_STAGE, options)

      Memtf.start(options)
    end

    it 'should set the runner variable' do
      Memtf.runner.should be_nil

      expected_runner = Memtf.start(options)

      Memtf.runner.should_not be_nil
      Memtf.runner.should == expected_runner
    end
  end

  describe '.finish' do
    it 'should delegate to Memtf::Runner' do
      Memtf::Runner.should_receive(:run).with(Memtf::FINISH_STAGE, hash_including(:group))

      Memtf.finish(options)
    end

    it 'should clear the runner variable' do
      runner = Memtf.start(options)
      Memtf.runner.should_not be_nil

      Memtf.finish(options)
      Memtf.runner.should be_nil
    end
  end

  describe '.around' do
    it 'should delegate to start' do
      Memtf.should_receive(:start).with(options)
      Memtf.stub(:finish)

      Memtf.around(options) { a = 1 + 2 }
    end

    it 'should delegate to finish' do
      Memtf.should_receive(:finish).with(options)

      Memtf.around(options) { a = 1 + 2 }
    end

    it 'should call the given block' do
      Memtf.stub(:finish)
      lambda = lambda { a = 1 + 2 }
      lambda.should_receive(:call)

      Memtf.around(options,&lambda)
    end
  end
end