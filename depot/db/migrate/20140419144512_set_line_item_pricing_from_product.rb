class SetLineItemPricingFromProduct < ActiveRecord::Migration
  def up
    LineItem.all.each do |item|
      item.price = item.product.price
    end
  end
end
