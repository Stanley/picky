require 'spec_helper'

describe Indexed::Category do

  before(:each) do
    @index               = stub :index, :name => :some_index
    @partial_strategy    = stub :partial, :use_exact_for_partial? => false
    @weights_strategy    = stub :weights
    @similarity_strategy = stub :similarity
    
    @exact   = stub :exact, :dump => nil
    @partial = stub :partial, :dump => nil
    
    @category = Indexed::Category.new :some_name, @index, :partial    => @partial_strategy,
                                                          :weights    => @weights_strategy,
                                                          :similarity => @similarity_strategy,
                                                          :qualifiers => [:q, :qualifier],
                                                          :exact_index_bundle => @exact,
                                                          :partial_index_bundle => @partial
    
    @category.stub! :exclaim
  end
  
  describe 'partial' do
    context 'with a partial strategy that uses the exact index' do
      before(:each) do
        @partial_strategy.stub! :use_exact_for_partial? => true
      end
      it 'returns the partial index' do
        @category.partial.should == @exact
      end
    end
    context 'with a partial strategy that uses the partial index (default)' do
      it 'returns the partial index' do
        @category.partial.should == @partial
      end
    end
  end
  
  describe 'generate_qualifiers_from' do
    context 'with qualifiers' do
      it 'returns that' do
        @category.generate_qualifiers_from(:qualifiers => [:a, :b]).should == [:a, :b]
      end
    end
    context 'without anything' do
      it 'returns that' do
        @category.generate_qualifiers_from({}).should == nil
      end
    end
    context 'with qualifier' do
      it 'returns that' do
        @category.generate_qualifiers_from(:qualifier => :a).should == [:a]
      end
    end
  end
  
  describe 'weight' do
    before(:each) do
      @token = stub :token, :text => :some_text
    end
    context 'partial bundle' do
      before(:each) do
        @category.stub! :bundle_for => @partial
      end
      it 'should receive weight with the token text' do
        @partial.should_receive(:weight).once.with :some_text

        @category.weight @token
      end
    end
    context 'exact bundle' do
      before(:each) do
        @category.stub! :bundle_for => @exact
      end
      it 'should receive weight with the token text' do
        @exact.should_receive(:weight).once.with :some_text

        @category.weight @token
      end
    end
  end

  describe 'ids' do
    before(:each) do
      @token = stub :token, :text => :some_text
    end
    context 'partial bundle' do
      before(:each) do
        @category.stub! :bundle_for => @partial
      end
      it 'should receive ids with the token text' do
        @partial.should_receive(:ids).once.with :some_text

        @category.ids @token
      end
    end
    context 'exact bundle' do
      before(:each) do
        @category.stub! :bundle_for => @exact
      end
      it 'should receive ids with the token text' do
        @exact.should_receive(:ids).once.with :some_text

        @category.ids @token
      end
    end
  end

  describe 'combination_for' do
    context 'no weight for token' do
      before(:each) do
        @category.stub! :weight => nil
      end
      it 'should return nil' do
        @category.combination_for(:anything).should == nil
      end
    end
    context 'weight for token' do
      before(:each) do
        @token = stub :token, :text => :some_text
        @category.stub! :weight => :some_weight, :bundle_for => :bundle
      end
      it 'should return a new combination' do
        @category.combination_for(@token).should be_kind_of(::Query::Combination)
      end
      it 'should create the combination correctly' do
        ::Query::Combination.should_receive(:new).once.with @token, @category

        @category.combination_for @token
      end
    end
  end

  describe 'bundle_for' do
    it 'should return the right bundle' do
      token = stub :token, :partial? => false

      @category.bundle_for(token).should == @exact
    end
    it 'should return the right bundle' do
      token = stub :token, :partial? => true

      @category.bundle_for(token).should == @partial
    end
  end
  
  describe 'load_from_cache' do
    it 'should call two methods' do
      @exact.should_receive(:load).once
      @partial.should_receive(:load).once
      
      @category.load_from_cache
    end
  end

end