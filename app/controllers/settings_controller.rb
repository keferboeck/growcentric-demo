class SettingsController < ApplicationController
  SECTIONS = %w[profile automation notifications integrations api content manufacturer team billing].freeze

  def show
    @section = params[:section]
    @products = Product.includes(:brand).order(:name) if @section == "api"
    @lumenride = Product.joins(:brand).where(brands: { name: "LumenRide" }).order(:name) if @section == "manufacturer"
    render "settings/show"
  end
end
