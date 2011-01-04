require 'spec_helper'

describe Indexing::Bundle do

  before(:each) do
    @category         = stub :category, :name => :some_category
    @index            = stub :index, :name => :some_index
    @configuration    = Configuration::Index.new @index, @category
    
    @partial_strategy = Cacher::Partial::Substring.new :from => 1
    @exact            = Indexing::Bundle.new :some_name, @configuration, nil, @partial_strategy, nil
  end

  def generate_random_keys amount
    alphabet = ('a'..'z').to_a
    (1..amount).to_a.collect! do |n|
      Array.new(20).collect! { alphabet[rand(26)] }.join.to_sym
    end
  end
  def generate_random_ids amount
    (1..amount).to_a.collect! do |_|
      Array.new(rand(100)+5).collect! do |_|
        rand(5_000_000)
      end
    end
  end

  describe 'speed' do
    context 'medium arrays' do
      before(:each) do
        random_keys  = generate_random_keys 300
        random_ids   = generate_random_ids  300
        @exact.index = Hash[random_keys.zip(random_ids)]
      end
      it 'should be fast' do
        performance_of do
          @exact.generate_partial
        end.should < 0.1
      end
    end
  end

end