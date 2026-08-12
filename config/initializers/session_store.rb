# The default cookie name would be derived from the internal project name.
# Use a clean public name instead.
Rails.application.config.session_store :cookie_store, key: "_growcentric_session"
