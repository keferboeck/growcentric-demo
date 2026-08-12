Rails.application.routes.draw do
  root "dashboard#index"

  # Login wall: Devise under friendly paths (/login, /logout, /password/reset).
  devise_for :users, path: "", path_names: { sign_in: "login", sign_out: "logout" }
  as :user do
    get "password/reset", to: "devise/passwords#new", as: :forgot_password
  end

  # Invite-only beta: no self-signup, /register just explains how to get access.
  get "register", to: "auth#register", as: :register

  get "legal/cookies", to: "legal#cookies", as: :legal_cookies
  post "track", to: "tracking#create"

  get "sherpa", to: "sherpa#index", as: :sherpa
  get "value-story", to: "value_story#index", as: :value_story
  get "content", to: "content#catalog", as: :content
  get "content/queue", to: "content#queue", as: :content_queue
  get "content/experiments", to: "content#experiments", as: :content_experiments

  get "hidden-potential", to: "products#index", as: :products
  get "competitors", to: "competitors#index", as: :competitors
  get "price-position", to: "price_position#index", as: :price_position
  get "delivery", to: "delivery#index", as: :delivery
  get "forecast", to: "forecast#index", as: :forecast
  get "campaigns", to: "campaigns#index", as: :campaigns
  get "dynamic-pricing", to: "dynamic_pricing#index", as: :dynamic_pricing
  get "recommendations", to: "recommendations#index", as: :recommendations
  get "resellers", to: "resellers#index", as: :resellers

  get "settings", to: redirect("/settings/automation")
  get "settings/:section", to: "settings#show", as: :settings_section,
      constraints: { section: /profile|automation|notifications|integrations|api|content|manufacturer|team|billing/ }

  get "up" => "rails/health#show", as: :rails_health_check
end
