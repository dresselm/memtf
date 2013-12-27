require 'spec_helper'

describe Memtf::Persistance do
  include FakeFS::SpecHelpers

  let(:name)  { 'test_name'  }
  let(:group) { 'test_group' }
  let(:date)  { '2013-12-26' }
  let(:pid)   { 9 }

  let(:expected_dir)       { "tmp/memtf/#{group}" }
  let(:expected_file_path) { "#{expected_dir}/#{name}-#{pid}.json" }

  before(:each) do
    Process.stub(:pid).and_return(pid)
  end

  describe '.save' do
    let(:payload) {{ :test => :payload }}

    context 'when the group directory does not exist' do
      it 'should create the directory' do
        Dir.exist?(expected_dir).should be_false
        described_class.save(name, group, payload)
        Dir.exist?(expected_dir).should be_true
      end
    end

    it 'should save the payload' do
      expected_file_path = "#{expected_dir}/#{name}-#{pid}.json"
      File.exist?(expected_file_path).should be_false
      described_class.save(name, group, payload)
      File.exist?(expected_file_path).should be_true
    end

    it 'should encode the payload' do
      described_class.save(name, group, payload)
      f = File.read(expected_file_path)
      f.should == "{\"test\":\"payload\"}"
    end
  end

  describe '.load' do
    before(:each) do
      FileUtils.mkdir_p(expected_dir)
      File.open(expected_file_path, 'w+') do |f|
        f.print("{\"test\":\"payload\"}")
      end
    end

    it 'should load the payload' do
      payload = described_class.load(name, group)
      payload.should_not be_nil
    end

    it 'should decode the payload' do
      payload = described_class.load(name, group)
      payload.should == { 'test' => 'payload' }
    end

    context 'when the file does not exist' do
      it 'should raise an Errno::ENOENT error' do
        expect {
          described_class.load("bogus_name", group)
        }.to raise_error(Errno::ENOENT)
      end
    end
  end
end