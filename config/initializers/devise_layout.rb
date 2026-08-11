# Devise screens (sign in, password reset) use the centered auth layout
# instead of the application shell with sidebar and topbar.
Rails.application.config.to_prepare do
  Devise::SessionsController.layout "auth"
  Devise::PasswordsController.layout "auth"
end
