require 'test_helper'

class UserStoriesTest < ActionDispatch::IntegrationTest
  fixtures [:products, :payment_types]

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

end
