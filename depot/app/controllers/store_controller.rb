class StoreController < ApplicationController
  include PageStats
  include CurrentCart

  skip_before_action :authorize

  before_action :set_cart
  before_action :visit, only: [:index]

  def index
    if params[:set_locale]
      redirect_to store_url(locale: params[:set_locale])
    else
      @products = Product.order(:title)
    end
  end
end
