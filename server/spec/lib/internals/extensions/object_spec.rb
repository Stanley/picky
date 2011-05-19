require 'spec_helper'

describe Object do
  
  context 'basic object' do
    let(:object) { described_class.new }
    
    describe "exclaim" do
      it "delegates to puts" do
        object.should_receive(:puts).once.with :bla

        object.exclaim :bla
      end
    end

    describe "timed_exclaim" do
      it "should exclaim right" do
        Time.stub! :now => Time.parse('07-03-1977 12:34:56')
        object.should_receive(:exclaim).once.with "12:34:56: bla"

        object.timed_exclaim 'bla'
      end
    end

    describe 'warn_gem_missing' do
      it 'should warn right' do
        object.should_receive(:warn).once.with "gnorf gem missing!\nTo use gnarble gnarf, you need to:\n  1. Add the following line to Gemfile:\n     gem 'gnorf'\n  2. Then, run:\n     bundle update\n"

        object.warn_gem_missing 'gnorf', 'gnarble gnarf'
      end
    end
  end
  
  describe 'indented_to_s' do
    describe String do
      let(:object) { described_class.new("Hello\nTest") }
      
      it 'indents a default amount' do
        object.indented_to_s.should == "  Hello\n  Test"
      end
      it 'indents twice' do
        object.indented_to_s.indented_to_s.should == "    Hello\n    Test"
      end
      it 'indents correctly' do
        object.indented_to_s(3).should == "   Hello\n   Test"
      end
    end
    describe Array do
      let(:object) { described_class.new(["Hello", "Test"]) }
      
      it 'indents a default amount' do
        object.indented_to_s.should == "  Hello\n  Test"
      end
      it 'indents twice' do
        object.indented_to_s.indented_to_s.should == "    Hello\n    Test"
      end
    end
  end
  
end