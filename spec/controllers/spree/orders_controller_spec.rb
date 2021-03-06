require 'spec_helper'

describe Spree::OrdersController do

  let(:order) {double(Spree::Order).as_null_object}
  let(:recurring_order) {double(Spree::RecurringOrder)}
  let(:user) { double(Spree::User, :last_incomplete_spree_order => nil, :has_spree_role? => true, :spree_api_key => 'fake').as_null_object }

  before :each do
    controller.stub :spree_current_user => user
    controller.stub :check_authorization
    allow(Spree::RecurringList).to receive(:build_from_order).and_return(nil)
  end

  describe 'show' do

    before :each do
      Spree::Order.stub(:find_by_number!).with("G2134").and_return(order)
      Spree::RecurringOrder.stub(:new).and_return(recurring_order)
    end

    it 'should assign order' do
      skip("Failing since spree upgrade")
      spree_get :show, id: "G2134"
      assigns(:order).should == order
    end

    it 'should assign recurring order' do
      skip("Failing since spree upgrade")
      spree_get :show, id: "G2134"
      assigns(:recurring_order).should == recurring_order
    end

    it 'should render show_recurring if order completed is true' do
      skip("Failing since spree upgrade")
      spree_get :show, {id: "G2134", order_completed: true}
      assigns(:present_recurring).should == true
      response.should render_template('show_completed')
    end

    it 'should render show normally' do
      skip("Failing since spree upgrade")
      spree_get :show, {id: "G2134"}
      assigns(:present_recurring).should == false
      response.should render_template('show')
    end

  end

end
