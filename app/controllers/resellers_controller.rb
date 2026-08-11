class ResellersController < ApplicationController
  def index
    @products = Product.joins(:brand).where(brands: { name: "LumenRide" }).order(:name)
  end
end
