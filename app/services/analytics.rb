# Server side event forwarding: GA4 Measurement Protocol, Meta Conversions
# API and LinkedIn Conversions API. Every sender is a no-op until its
# environment variables are set, and failures never surface: tracking must
# not break requests. Events themselves get defined as the product grows;
# call Analytics.track from anywhere server side, or let the /track endpoint
# relay browser events.
require "net/http"
require "json"

module Analytics
  GA_MEASUREMENT_ID = ENV.fetch("GA_MEASUREMENT_ID", "")
  GA4_API_SECRET = ENV.fetch("GA4_API_SECRET", "")
  META_PIXEL_ID = ENV.fetch("META_PIXEL_ID", "")
  META_CAPI_ACCESS_TOKEN = ENV.fetch("META_CAPI_ACCESS_TOKEN", "")
  LINKEDIN_CAPI_ACCESS_TOKEN = ENV.fetch("LINKEDIN_CAPI_ACCESS_TOKEN", "")

  module_function

  # name: event name string
  # properties: arbitrary event parameters
  # client_id: GA client id (from the _ga cookie), one is generated if absent
  # fbp/fbc: Meta browser and click cookies for attribution
  # ip/user_agent/url: request context
  # linkedin_conversion_urn: "urn:lla:llaPartnerConversion:<id>" when the
  #   event maps to a LinkedIn conversion rule
  def track(name, properties: {}, client_id: nil, fbp: nil, fbc: nil,
            ip: nil, user_agent: nil, url: nil, linkedin_conversion_urn: nil)
    send_ga4(name, properties, client_id)
    send_meta(name, properties, fbp: fbp, fbc: fbc, ip: ip, user_agent: user_agent, url: url)
    send_linkedin(linkedin_conversion_urn)
  end

  def send_ga4(name, properties, client_id)
    return if GA_MEASUREMENT_ID.empty? || GA4_API_SECRET.empty?
    uri = URI("https://www.google-analytics.com/mp/collect" \
              "?measurement_id=#{GA_MEASUREMENT_ID}&api_secret=#{GA4_API_SECRET}")
    post_json(uri, {
      client_id: client_id.presence || SecureRandom.uuid,
      events: [ { name: name, params: properties } ]
    })
  end

  def send_meta(name, properties, fbp: nil, fbc: nil, ip: nil, user_agent: nil, url: nil)
    return if META_PIXEL_ID.empty? || META_CAPI_ACCESS_TOKEN.empty?
    uri = URI("https://graph.facebook.com/v21.0/#{META_PIXEL_ID}/events" \
              "?access_token=#{META_CAPI_ACCESS_TOKEN}")
    post_json(uri, {
      data: [ {
        event_name: name,
        event_time: Time.current.to_i,
        action_source: "website",
        event_source_url: url,
        user_data: {
          client_ip_address: ip,
          client_user_agent: user_agent,
          fbp: fbp,
          fbc: fbc
        }.compact,
        custom_data: properties
      } ]
    })
  end

  def send_linkedin(conversion_urn)
    return if LINKEDIN_CAPI_ACCESS_TOKEN.empty? || conversion_urn.blank?
    uri = URI("https://api.linkedin.com/rest/conversionEvents")
    post_json(uri, {
      conversion: conversion_urn,
      conversionHappenedAt: (Time.current.to_f * 1000).to_i,
      user: { userIds: [] }
    }, headers: {
      "Authorization" => "Bearer #{LINKEDIN_CAPI_ACCESS_TOKEN}",
      "LinkedIn-Version" => "202411"
    })
  end

  def post_json(uri, payload, headers: {})
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.open_timeout = 2
    http.read_timeout = 3
    request = Net::HTTP::Post.new(uri, { "Content-Type" => "application/json" }.merge(headers))
    request.body = payload.to_json
    http.request(request)
  rescue StandardError => e
    Rails.logger.warn("Analytics send failed: #{e.class}: #{e.message}")
    nil
  end
end
