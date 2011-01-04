require 'spec_helper'

describe Indexing::Category do
  
  before(:each) do
    @index = stub :index, :name => :some_index
    @category = Indexing::Category.new :some_category, @index, :source => :some_given_source
  end
  context "unit specs" do
    before(:each) do
      @exact = @category.exact
      @partial = @category.partial
    end
    describe 'dump_caches' do
      before(:each) do
        @exact.stub! :dump
        @partial.stub! :dump
      end
      it 'should dump the exact index' do
        @exact.should_receive(:dump).once.with

        @category.dump_caches
      end
      it 'should dump the partial index' do
        @partial.should_receive(:dump).once.with

        @category.dump_caches
      end
    end
    
    describe 'generate_caches_from_memory' do
      it 'should delegate to partial' do
        @partial.should_receive(:generate_caches_from_memory).once.with
        
        @category.generate_caches_from_memory
      end
    end
    
    describe 'generate_partial' do
      it 'should return whatever the partial generation returns' do
        @exact.stub! :index
        @partial.stub! :generate_partial_from => :generation_returns

        @category.generate_partial
      end
      it 'should use the exact index to generate the partial index' do
        exact_index = stub :exact_index
        @exact.stub! :index => exact_index
        @partial.should_receive(:generate_partial_from).once.with(exact_index)

        @category.generate_partial
      end
    end

    describe 'generate_caches_from_source' do
      it 'should delegate to exact' do
        @exact.should_receive(:generate_caches_from_source).once.with

        @category.generate_caches_from_source
      end
    end

    describe 'generate_caches' do
      it 'should call multiple methods in order' do
        @category.should_receive(:generate_caches_from_source).once.with().ordered
        @category.should_receive(:generate_partial).once.with().ordered
        @category.should_receive(:generate_caches_from_memory).once.with().ordered
        @category.should_receive(:dump_caches).once.with().ordered
        @category.should_receive(:timed_exclaim).once.ordered
        
        @category.generate_caches
      end
    end
    
    describe "cache" do
      before(:each) do
        @category.stub! :generate_caches
      end
      it "prepares the cache directory" do
        @category.should_receive(:prepare_index_directory).once.with
        
        @category.cache
      end
      it "tells the indexer to index" do
        @category.should_receive(:generate_caches).once.with
        
        @category.cache
      end
    end
    describe "index" do
      before(:each) do
        @indexer = stub :indexer, :index => nil
        @category.stub! :indexer => @indexer
      end
      it "prepares the cache directory" do
        @category.should_receive(:prepare_index_directory).once.with
        
        @category.index
      end
      it "tells the indexer to index" do
        @indexer.should_receive(:index).once.with
        
        @category.index
      end
    end
    describe "source" do
      context "without source" do
        it "raises" do
          lambda { Indexing::Category.new :some_name, @index }.should raise_error(Indexers::NoSourceSpecifiedException)
        end
      end
    end
  end
  
end