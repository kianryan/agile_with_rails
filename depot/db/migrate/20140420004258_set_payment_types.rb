class SetPaymentTypes < ActiveRecord::Migration

  def up
    PaymentType.delete_all
    PaymentType.create!(name: "Check")
    PaymentType.create!(name: "Credit card")
    PaymentType.create!(name: "Purchase order")

    Order.all.each do |order|
      order.payment_type = PaymentType.find_by(name: order.pay_type)
      order.save!
    end
  end

  def down
    Order.all.each do |order|
      order.pay_type = order.payment_type.name
      order.payment_type = nil
      order.save!
    end

  end

end
