require 'spec_helper'

describe Memtf::Analyzer do
  describe '.analyze' do
    it 'should create a new Analyzer'
    it 'should delegate to analyze'
  end

  describe '.analyze_group' do
    it 'should load the start data'
    it 'should load the end data'
    it 'should compare the start and end data'
    it 'should generate an impact value'
  end

  describe '#analyze' do
    it 'should try to garbage collect'
    it 'should calculate the total memory allocated to each class'
    it 'should isolate classes that exceed a given memory threshold'
    it 'should generate an aggregated Others* row'
    it 'should translate the results into a simple hash'
  end
end