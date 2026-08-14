class ApplicationController < ActionController::Base
  around_action :switch_locale
  before_action :switch_currency
  before_action :authenticate_user!, unless: :devise_controller?
  after_action :rewrite_currency

  helper_method :current_currency

  private

  def switch_locale(&action)
    session[:locale] = params[:locale] if params[:locale].present? && I18n.available_locales.map(&:to_s).include?(params[:locale])
    I18n.with_locale(session[:locale] || detected_locale, &action)
  end

  # Display currency for localised screenshots (?currency=GBP). Data stays
  # euro-denominated; DemoCurrency rewrites amounts in the rendered HTML.
  def switch_currency
    session[:currency] = params[:currency] if DemoCurrency::CURRENCIES.key?(params[:currency].to_s)
  end

  def current_currency
    session[:currency] || "EUR"
  end

  def rewrite_currency
    return if current_currency == "EUR"
    return unless response.media_type == "text/html" && response.body.present?

    response.body = DemoCurrency.rewrite(response.body, current_currency)
  end

  # Locale resolution when the visitor has not picked a language yet:
  #   1. Browser language (Accept-Language) when it names a language we support.
  #   2. Geo: requests from the DACH region default to German. App Platform sits
  #      behind Cloudflare, so the country arrives in CF-IPCountry when present.
  #   3. English.
  # Only the explicit flag-toggle choice is stored in the session, so changing
  # the browser language keeps working until the visitor picks a language.
  DACH_COUNTRIES = %w[DE AT CH LI].freeze

  def detected_locale
    supported = I18n.available_locales.map(&:to_s)
    browser = request.headers["Accept-Language"].to_s.downcase.scan(/[a-z]{2}(?=[-;,\s]|\z)/).find { |lang| supported.include?(lang) }
    return browser if browser

    country = (request.headers["CF-IPCountry"] || request.headers["X-Country-Code"] || request.headers["X-Geo-Country"]).to_s.upcase
    return "de" if DACH_COUNTRIES.include?(country)

    I18n.default_locale.to_s
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
