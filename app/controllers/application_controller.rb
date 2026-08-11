class ApplicationController < ActionController::Base
  around_action :switch_locale
  before_action :authenticate_user!, unless: :devise_controller?

  private

  def switch_locale(&action)
    session[:locale] = params[:locale] if params[:locale].present? && I18n.available_locales.map(&:to_s).include?(params[:locale])
    I18n.with_locale(session[:locale] || I18n.default_locale, &action)
  end

  # Shared product filtering for the analysis pages. All filters arrive as GET
  # params so filtered views are linkable and screenshot-friendly.
  def filter_products(scope)
    scope = scope.joins(category: :department).where(departments: { name: params[:department] }) if params[:department].present?
    scope = scope.joins(:category).where(categories: { name: params[:category] }) if params[:category].present?
    scope = scope.joins(:brand).where(brands: { name: params[:brand] }) if params[:brand].present?
    case params[:tier]
    when "Entry"   then scope = scope.where("price_cents < 5000")
    when "Mid"     then scope = scope.where(price_cents: 5000..15_000)
    when "Premium" then scope = scope.where("price_cents > 15000")
    end
    scope = scope.where(season: params[:season]) if params[:season].present?
    scope
  end

  def filters_active?
    %i[department category brand tier season].any? { |key| params[key].present? }
  end
  helper_method :filters_active?
end
