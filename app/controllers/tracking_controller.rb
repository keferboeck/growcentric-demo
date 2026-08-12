class TrackingController < ApplicationController
  # Beacon requests carry no CSRF token and may arrive from the login screen.
  skip_before_action :authenticate_user!
  skip_before_action :verify_authenticity_token

  # Relays browser events to the server side APIs (GA4 Measurement Protocol,
  # Meta and LinkedIn Conversions APIs). Only forwards with accepted consent.
  def create
    payload = JSON.parse(request.body.read) rescue {}
    name = payload["name"].to_s
    return head :bad_request if name.empty?
    return head :ok unless cookies["gc_cookie_consent"] == "accepted"

    ga = cookies["_ga"].to_s
    Analytics.track(
      name,
      properties: payload["properties"].is_a?(Hash) ? payload["properties"] : {},
      client_id: ga.split(".").last(2).join("."),
      fbp: cookies["_fbp"],
      fbc: cookies["_fbc"],
      ip: request.remote_ip,
      user_agent: request.user_agent,
      url: payload["url"]
    )
    head :ok
  end
end
