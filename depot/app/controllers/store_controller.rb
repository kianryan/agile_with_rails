class StoreController < ApplicationController
  include PageStats
  include CurrentCart

  before_action :set_cart
  before_action :visit, only: [:index]

  def index
    @products = Product.order(:title)
  end
end
