class AuthController < ApplicationController
  layout "auth"
  skip_before_action :authenticate_user!

  # Invite-only beta: the register page explains how to get access.
  def register
  end
end
