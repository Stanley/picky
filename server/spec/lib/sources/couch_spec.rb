require 'spec_helper'

describe Sources::Couch do
  
  describe 'UUIDKeys' do
    before(:each) do
      @keys = Sources::Couch::UUIDKeys.new
    end
    it 'converts uuids' do
      @keys.to_i('550e8400-e29b-41d4-a716-446655440000').should == 113059749145936325402354257176981405696
    end
  end
  describe 'HexKeys' do
    before(:each) do
      @keys = Sources::Couch::HexKeys.new
    end
    it 'converts uuids' do
      @keys.to_i('7f').should == 127
    end
  end
  describe 'IntegerKeys' do
    before(:each) do
      @keys = Sources::Couch::IntegerKeys.new
    end
    it 'converts uuids' do
      @keys.to_i('123').should == '123'
    end
  end
  
  describe 'special keys' do
    context 'uuid keys' do
      context "with database" do
        before(:each) do
          @source = Sources::Couch.new :a, :b, :c, url: 'http://localhost:5984/picky', keys: Sources::Couch::UUIDKeys.new
          RestClient::Request.should_receive(:execute).any_number_of_times.and_return %{{"rows":[{"doc":{"_id":"550e8400-e29b-41d4-a716-446655440000","a":"a data","b":"b data","c":"c data"}}]}}
        end

        describe "harvest" do
          it "yields the right data" do
            field = stub :b, :from => :b
            @source.harvest :anything, field do |id, token|
              id.should    eql(113059749145936325402354257176981405696) 
              token.should eql('b data')
            end.should have(1).item
          end
        end

        describe "get_data" do
          it "yields each line" do
            @source.get_data do |data|
              data.should == { "_id" => "550e8400-e29b-41d4-a716-446655440000", "a" => "a data", "b" => "b data", "c" => "c data" }
            end.should have(1).item
          end
        end
      end
    end
    context 'integer keys' do
      context "with database" do
        before(:each) do
          @source = Sources::Couch.new :a, :b, :c, url: 'http://localhost:5984/picky', keys: Sources::Couch::IntegerKeys.new
          RestClient::Request.should_receive(:execute).any_number_of_times.and_return %{{"rows":[{"doc":{"_id":"123","a":"a data","b":"b data","c":"c data"}}]}}
        end

        describe "harvest" do
          it "yields the right data" do
            field = stub :b, :from => :b
            @source.harvest :anything, field do |id, token|
              id.should    eql('123') 
              token.should eql('b data')
            end.should have(1).item
          end
        end

        describe "get_data" do
          it "yields each line" do
            @source.get_data do |data|
              data.should == { "_id" => "123", "a" => "a data", "b" => "b data", "c" => "c data" }
            end.should have(1).item
          end
        end
      end
    end
  end
  
  context 'default keys' do
    context "without database" do
      it "should fail correctly" do
        lambda { @source = Sources::Couch.new(:a, :b, :c) }.should raise_error(Sources::NoCouchDBGiven)
      end
    end

    context "with database" do
      before(:each) do
        @source = Sources::Couch.new :a, :b, :c, url: 'http://localhost:5984/picky'
        RestClient::Request.should_receive(:execute).any_number_of_times.and_return %{{"rows":[{"doc":{"_id":"7f","a":"a data","b":"b data","c":"c data"}}]}}
      end

      describe "harvest" do
        it "yields the right data" do
          field = stub :b, :from => :b
          @source.harvest :anything, field do |id, token|
            id.should    eql(127) 
            token.should eql('b data')
          end.should have(1).item
        end
      end

      describe "get_data" do
        it "yields each line" do
          @source.get_data do |data|
            data.should == { "_id" => "7f", "a" => "a data", "b" => "b data", "c" => "c data" }
          end.should have(1).item
        end
      end
    end
  end
end
