require 'spec_helper'

describe Indexed::Indexes do

  context 'after initialize' do
    let(:indexes) { described_class.new }
    it 'has an empty mapping' do
      indexes.index_mapping.should == {}
    end
    it 'has no indexes' do
      indexes.indexes.should == []
    end
  end
  
  describe 'methods' do
    let(:indexes) { described_class.new }
    before(:each) do
      @index1 = stub :index1, :name => :index1
      @index2 = stub :index2, :name => :index2
      indexes.register @index1
      indexes.register @index2
    end
    describe '[]' do
      it 'should use the mapping' do
        indexes[:index2].should == @index2
      end
      it 'should allow strings' do
        indexes['index1'].should == @index1
      end
    end
    describe 'register' do
      it 'should have indexes' do
        indexes.indexes.should == [@index1, @index2]
      end
      it 'should have a mapping' do
        indexes.index_mapping.should == { :index1 => @index1, :index2 => @index2 }
      end
    end
    describe 'clear' do
      it 'clears the indexes' do
        indexes.clear
        
        indexes.indexes.should == []
      end
      it 'clears the mapping' do
        indexes.clear
        
        indexes.index_mapping.should == {}
      end
    end
    describe 'reload' do
      it 'calls load_from_cache on each in order' do
        @index1.should_receive(:load_from_cache).once.with.ordered
        @index2.should_receive(:load_from_cache).once.with.ordered

        indexes.reload
      end
    end
  end
  
end