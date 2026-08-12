class LegalController < ApplicationController
  layout "auth"
  skip_before_action :authenticate_user!

  def cookies
  end
end
