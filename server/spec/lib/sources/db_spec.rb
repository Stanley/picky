require 'spec_helper'

describe Sources::DB do
  
  before(:each) do
    @type       = stub :type, :name => 'some_type_name'
    
    @connection = stub :connection
    @adapter    = stub :adapter, :connection => @connection
    
    @select_statement = stub :statement
    
    @source = Sources::DB.new @select_statement, :option => :some_options
    
    @source.stub! :database => @adapter
    @source.stub! :connect_backend
  end
  
  describe "get_data" do
    before(:each) do
      @type     = stub :type,     :name => :some_type
      @category = stub :category, :from => :some_category
    end
    context 'no data' do
      it "delegates to the connection" do

        @connection.should_receive(:execute).
                    once.
                    with('SELECT indexed_id, some_category FROM some_type_type_index st WHERE st.id > some_offset LIMIT 25000').
                    and_return []

        @source.get_data @type, @category, :some_offset
      end
    end
    context 'with data' do
      it 'yields to the caller' do
        @connection.should_receive(:execute).
                    any_number_of_times.
                    with('SELECT indexed_id, some_category FROM some_type_type_index st WHERE st.id > some_offset LIMIT 25000').
                    and_return [[1, 'text']]

        @source.get_data @type, @category, :some_offset do |id, text|
          id.should == 1
          text.should == 'text'
        end
      end
    end
  end
  
  describe "configure" do
    it "works" do
      lambda { @source.configure({}) }.should_not raise_error
    end
    context "with file" do
      it "opens the config file relative to root" do
        File.should_receive(:open).once.with 'spec/test_directory/app/bla.yml'
        
        @source.configure :file => 'app/bla.yml'
      end
    end
  end
  
  describe "connect_backend" do
    it "works" do
      lambda { @source.connect_backend }.should_not raise_error
    end
  end
  
  describe "chunksize" do
    it "should be a specific size" do
      @source.chunksize.should == 25_000
    end
  end
  
  describe "count" do
    it "should get the count through the public DB connection" do
      result = stub(:result, :to_i => 12_345)
      @connection.should_receive(:select_value).once.and_return(result)
      
      @source.count @type
    end
    it "should get the id count" do
      result = stub(:result, :to_i => 12_345)
      @connection.should_receive(:select_value).once.with("SELECT COUNT(id) FROM some_type_name_type_index")
      
      @source.count @type
    end
  end
  
  describe 'harvest' do
    before(:each) do
      @type     = stub :type,     :name => :some_type
      @category = stub :category, :name => :some_category

      @source.should_receive(:get_data).any_number_of_times.and_return [[:some_id, 'some_text']].cycle
      @source.stub! :count => 17
    end
    it 'calls connect_backend' do
      @source.should_receive(:connect_backend).once.with()
      
      @source.harvest @type, @category do |id, text|
        p [id, text]
      end
    end
  end

  describe "harvest_statement_with_offset" do
    before(:each) do
      @category = stub :category, :from => :some_category
      @type     = stub :type,     :name => :some_type
    end
    it "should get a harvest statement and the chunksize to put the statement together" do
      @source.should_receive(:harvest_statement).once.with(@type, @category).and_return 'some_example_statement'
      @source.harvest_statement_with_offset(@type, @category, :some_offset)
    end
    it "should add an AND if it already contains a WHERE statement" do
      @source.should_receive(:harvest_statement).and_return 'WHERE'
      @source.harvest_statement_with_offset(@type, @category, :some_offset).should == "WHERE AND st.id > some_offset LIMIT 25000"
    end
    it "should add a WHERE if it doesn't already contain one" do
      @source.should_receive(:harvest_statement).and_return 'some_statement'
      @source.harvest_statement_with_offset(@type, @category, :some_offset).should == "some_statement WHERE st.id > some_offset LIMIT 25000"
    end
  end
  
end