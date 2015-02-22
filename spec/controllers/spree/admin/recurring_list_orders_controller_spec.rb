require 'spec_helper'

describe Spree::Admin::RecurringListOrdersController do

  let(:user) { double Spree::User, :last_incomplete_spree_order => nil, :has_spree_role? => true, :spree_api_key => 'fake' }

  before :each do
    controller.stub :spree_current_user => user
    controller.stub :check_authorization
  end

  describe 'create' do

    describe 'integration' do

      it 'should create new order based on recurring list' do
        address = FactoryGirl.create(:address)
        old_order = FactoryGirl.create(:order, state: 'complete', completed_at: Time.now, ship_address: address, bill_address: address)
        user = FactoryGirl.build(:user, email: 'test@email.com', orders: [old_order])
        recurring_list = FactoryGirl.build(:recurring_list, user: user)
        recurring_order = Spree::RecurringOrder.create(recurring_lists: [recurring_list])

        spree_post :create, recurring_order_id: recurring_order.id 

        created_order = Spree::Order.last
        expect(created_order.email).to eq(user.email)
        expect(created_order.created_by).to eq(user)
      end

    end

    context 'mocks' do

      let(:new_order){double(Spree::Order, id: 123, number: 'A123').as_null_object}
      let(:order_contents){double(Spree::OrderContents).as_null_object}
      let(:normal_user){double(Spree::User, email: 'test@email.com').as_null_object}
      let(:item){FactoryGirl.build(:recurring_list_item)}
      let(:base_list){double(Spree::RecurringList, user: normal_user, items: [item])}
      let(:recurring_order){double(Spree::RecurringOrder, id: 1, base_list: base_list)}

      before :each do
        allow(Spree::RecurringOrder).to receive(:find).with("1").and_return(recurring_order)
        allow(Spree::Order).to receive(:create).and_return(new_order)

        allow(Spree::OrderContents).to receive(:new).and_return(order_contents)
        allow(order_contents).to receive(:add)
      end

      it 'should set email and created by' do
        expect(new_order).to receive(:email=).with('test@email.com')
        expect(new_order).to receive(:created_by=).with(normal_user)
        spree_post :create, recurring_order_id: recurring_order.id 
      end

      it 'should add items from base list' do
        expect(Spree::OrderContents).to receive(:new).with(new_order).and_return(order_contents)
        expect(order_contents).to receive(:add).with(item.variant, item.quantity)

        spree_post :create, recurring_order_id: recurring_order.id 
      end

      it 'should redirect to new order path' do
        spree_post :create, recurring_order_id: recurring_order.id 
        expect(response).to redirect_to("/admin/orders/#{new_order.number}/edit")
      end

      it 'should fail if recurring order doesnt have a base list'
      it 'should display error if delivery time is invalid'
      it 'should fail if user has already an order in progress'
      it 'should merge with cart order if user has one'
    end

  end

end
