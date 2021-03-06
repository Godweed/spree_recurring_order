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
        user = FactoryGirl.create(:user, email: 'test@email.com')
        old_order = FactoryGirl.create(:order, user: user, state: 'complete', completed_at: Time.now, ship_address: address, bill_address: address)
        recurring_list = FactoryGirl.create(:recurring_list, user: user)
        recurring_order = Spree::RecurringOrder.create(recurring_lists: [recurring_list])

        spree_post :create, recurring_order_id: recurring_order.id, complete_after_create: "0"

        created_order = Spree::Order.last
        expect(created_order.email).to eq(user.email)
        expect(created_order.created_by).to eq(user)
      end

    end

    context 'mocks' do

      let(:new_order){double(Spree::Order, id: 123, number: 'A123', delivery_date: nil, valid?: true).as_null_object}
      let(:order_contents){double(Spree::OrderContents).as_null_object}
      let(:normal_user){double(Spree::User, email: 'test@email.com', has_incomplete_order_booked?: false).as_null_object}
      let(:item){FactoryGirl.build(:recurring_list_item)}
      let(:base_list){double(Spree::RecurringList, user: normal_user, items: [item]).as_null_object}
      let(:recurring_order){double(Spree::RecurringOrder, id: 1, number: '1234', base_list: base_list, complete_after_create: false)}

      before :each do
        allow(Spree::RecurringOrder).to receive(:find).with("1").and_return(recurring_order)
        allow(Spree::Order).to receive(:new).and_return(new_order)

        allow(recurring_order).to receive(:complete_after_create=).and_return(false)
        allow(recurring_order).to receive(:save)
        allow(Spree::OrderContents).to receive(:new).and_return(order_contents)
        allow(order_contents).to receive(:add)
      end

      it 'should redirect to new order path' do
        allow(recurring_order).to receive(:create_order_from_base_list).and_return(new_order)
        spree_post :create, recurring_order_id: recurring_order.id, complete_after_create: "0"
        expect(response).to redirect_to("/admin/orders/#{new_order.number}/edit")
      end

      it 'should fail if recurring order doesnt have a base list' do
        invalid_recurring_order = double(Spree::RecurringOrder, id: 1, number: '1234', base_list: nil)
        allow(Spree::RecurringOrder).to receive(:find).and_return(invalid_recurring_order)

        spree_post :create, recurring_order_id: recurring_order.id, complete_after_create: "0"
        expect(response).to redirect_to("/admin/recurring_orders/#{invalid_recurring_order.number}")
      end

      it 'should fail if order validation fails' do
        allow(new_order).to receive(:valid?).and_return false
        allow(recurring_order).to receive(:create_order_from_base_list).and_return(new_order)
        spree_post :create, recurring_order_id: recurring_order.id, complete_after_create: "0"
        expect(response).to redirect_to("/admin/recurring_orders/#{recurring_order.number}")
      end

    end

  end

end
