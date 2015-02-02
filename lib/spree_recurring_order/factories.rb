FactoryGirl.define do
  factory :recurring_list_item, class: Spree::RecurringListItem do
    variant
    quantity 1
  end

  factory :recurring_list, class: Spree::RecurringList do
    user
    timeslot '6am to 7:30am'
    next_delivery_date Date.tomorrow
    after(:build) do |list|
      list.items << FactoryGirl.build(:recurring_list_item)
    end
  end
end
