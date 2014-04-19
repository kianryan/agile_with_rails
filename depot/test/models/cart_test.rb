require 'test_helper'

class CartTest < ActiveSupport::TestCase
  test "same item is not duplicated in cart" do
    cart = Cart.new
    ruby = products(:ruby)

    line_item = cart.add_product(ruby.id)
    line_item.save

    line_item = cart.add_product(ruby.id)
    line_item.save

    assert_equal 1, cart.line_items.count 
  end

  test "different item creates a second line" do
    cart = Cart.new
    ruby = products(:ruby)
    tmux = products(:tmux)

    line_item = cart.add_product(ruby.id)
    line_item.save

    line_item = cart.add_product(tmux.id)
    line_item.save

    assert_equal 2, cart.line_items.count 
  end

end
