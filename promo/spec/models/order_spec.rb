require File.dirname(__FILE__) + '/../spec_helper'

describe Order do

  let(:order) { Factory(:order) }

  context "#update_adjustments" do

    it "should make all but the most valuable promotion adjustment ineligible, leaving non promotion adjustments alone" do
      Factory(:adjustment, :order => order, :label => 'Promotion A', :amount => -100)
      Factory(:adjustment, :order => order, :label => 'Promotion B', :amount => -200)
      Factory(:adjustment, :order => order, :label => 'Promotion C', :amount => -300)
      Factory(:adjustment, :order => order, :label => 'Some other credit', :amount => -500)
      order.adjustments.each {|a| a.update_attribute_without_callbacks(:eligible, true)}

      order.send(:update_adjustments)
      order.adjustments.eligible.promotion.count.should == 1
      order.adjustments.eligible.promotion.first.label.should == 'Promotion C'
    end

    it "should only leave one adjustment even if 2 have the same amount" do
      Factory(:adjustment, :order => order, :label => 'Promotion A', :amount => -100)
      Factory(:adjustment, :order => order, :label => 'Promotion B', :amount => -200)
      Factory(:adjustment, :order => order, :label => 'Promotion C', :amount => -200)

      order.send(:update_adjustments)
      order.adjustments.eligible.promotion.count.should == 1
      order.adjustments.eligible.promotion.first.amount.to_i.should == -200
    end

  end

end

