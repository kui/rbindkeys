# -*- coding:utf-8; mode:ruby; -*-

require 'rbindkeys'

include Rbindkeys

describe BindTree do
  context "normal" do
    describe 'BindTree#bind' do
      before do
        @bt = BindTree.new
      end

      context 'with valid input/output' do
        it "should construct expected tree" do
          input = [1,2]
          @bt.bind input, [2,3]
          input.should == [1,2] # should not destroyable
          @bt.bind [1,0], [2,3]
          @bt.bind [2], [2,4]
          @bt.tree[1][2].payload.output.should == [2,3]
          @bt.tree[1][0].payload.output.should == [2,3]
          @bt.tree[2].payload.output.should == [2,4]
        end
      end
      context 'with duplicate node input' do
        it "should raise DuplicateNodeError" do
          @bt.bind [1,2], [2,3]
          begin
            @bt.bind [1,2], [2,4]
            violated "should raise"
          rescue => e
            e.class.should == BindTree::DuplicateNodeError
          end
        end
        it "should raise DuplicateNodeError" do
          @bt.bind [1,2], [2,3]
          begin
            @bt.bind [1,2,6], [2,4]
            violated "should raise"
          rescue => e
            e.class.should == BindTree::DuplicateNodeError
          end
        end
      end
    end # describe
  end # context
end # describe
