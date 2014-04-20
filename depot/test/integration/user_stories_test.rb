require 'test_helper'

class UserStoriesTest < ActionDispatch::IntegrationTest
  fixtures [:products, :payment_types, :orders]

  # A user goes to the index page.  They select a product
  # adding it to their cart, and check out, filling in their
  # details on the checkout form.  When they submit, an order 
  # is created containing their information, along with a 
  # single line item corresponding to the product they added
  # to their cart.
  
  test "buying a product" do
    # Set up
    LineItem.delete_all
    Order.delete_all
    ActionMailer::Base.deliveries.clear
    ruby_book = products(:ruby)
    payment_type = payment_types(:one)

    # Return store-front page
    get "/"
    assert_response :success
    assert_template "index"

    # Add book to basket
    xml_http_request :post, '/line_items', product_id: ruby_book.id
    assert_response :success

    # Check contents of cart
    cart = Cart.find(session[:cart_id])
    assert_equal 1, cart.line_items.size
    assert_equal ruby_book, cart.line_items[0].product

    # Visit checkout page
    get "/orders/new"
    assert_response :success
    assert_template "new"

    # Post order details
    post_via_redirect "/orders",
      order: {  name:             "Dave Thomas",
                address:          "123 The Street",
                email:            "dave@hotmail.com",
                payment_type_id:  payment_type.id }
    assert_response :success
    assert_template "index"

    # Check cart is empty
    cart = Cart.find(session[:cart_id])
    assert_equal 0, cart.line_items.size

    # Check details of placed order
    orders = Order.all
    assert_equal 1, orders.size
    order = orders[0]

    assert_equal "Dave Thomas",       order.name
    assert_equal "123 The Street",    order.address
    assert_equal "dave@hotmail.com",  order.email
    assert_equal payment_type,        order.payment_type

    # Check line item on order
    assert_equal 1, order.line_items.size
    line_item = order.line_items[0]
    assert_equal ruby_book, line_item.product

    # Ensure mail was delivered
    mail = ActionMailer::Base.deliveries.last
    assert_equal ["dave@hotmail.com"], mail.to
    assert_equal "Pragmatic Store Order Confirmation", mail.subject
  end

  # An user updates an order.  The order does
  # not change the shipped date so the shipped 
  # mail is not sent
  test "updating an order" do
    order = orders(:one)
    ActionMailer::Base.deliveries.clear

    put_via_redirect "/orders/" + order.id.to_s,
      order: { name: "Dave Tinsley" }
    assert_response :success

    # Check changed attribute
    order = Order.find(order.id)
    assert_equal "Dave Tinsley", order.name

    # Ensure no mail sent
    assert_equal 0, ActionMailer::Base.deliveries.count
  end
  #
  # An user updates an order.  The order does
  # change the shipped date so the shipped 
  # mail is not sent
  test "updating an order, changing shipped date" do
    order = orders(:one)
    now = Date.today
    ActionMailer::Base.deliveries.clear

    put_via_redirect "/orders/" + order.id.to_s,
      order: { ship_date: now }
    assert_response :success

    # Check changed attribute
    order = Order.find(order.id)
    assert_equal now, order.ship_date

    # Ensure mail sent
    assert_equal 1, ActionMailer::Base.deliveries.count
    mail = ActionMailer::Base.deliveries.last
    assert_equal ["dave@hotmail.com"], mail.to
    assert_equal "Pragmatic Store Order Shipped", mail.subject
  end

  # Attempting to access a cart with an invalid
  # id should send a log message and redirect the user
  test "accessing an invalid cart" do
    get_via_redirect "/carts/invalid_cart_name"
    
    assert_response :success
    assert_equal 'Invalid cart', flash[:notice]

    # Ensure mail sent
    assert_equal 1, ActionMailer::Base.deliveries.count
    mail = ActionMailer::Base.deliveries.last
    assert_equal ["admin@depot.com"], mail.to
  end
end
