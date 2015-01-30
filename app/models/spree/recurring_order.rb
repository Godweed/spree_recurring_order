module Spree
  class RecurringOrder < ActiveRecord::Base

    validate :at_least_one_order_or_list

    has_many :orders
    has_many :recurring_lists

    belongs_to :original_order, class_name: 'Spree::Order'

    after_create :generate_order_number

    def self.create_from_order(order)
      recurring_order = RecurringOrder.new
      recurring_order.orders << order
      recurring_order.save!
      recurring_order
    end

    def original_order
      @original_order ||= orders.sort_by{|order| order.created_at}.first
    end

    def email
      original_order.email
    end

    def phone
      original_order.ship_address.phone rescue ''
    end

    private

    def at_least_one_order_or_list
      if orders.empty? && recurring_lists.empty?
        self.errors[:base] << "recurring order needs a order or a recurring list"
      end
    end

    def generate_order_number
      record = true
      while record
        random = "R#{Array.new(6){rand(6)}.join}"
        record = self.class.where(number: random).first
      end
      self.number = random if self.number.blank?
      self.number
      self.save!
    end

  end
end
