class StoreController < ApplicationController
  include PageStats

  before_action :visit, only: [:index]

  def index
    @products = Product.order(:title)
  end
end
