# Public landing page for velora.keferboeck.com, the fictional shop domain the
# demo references everywhere. No login wall, and no currency rewrite: the feed
# stays euro denominated so the polled JSON and the rendered page always match.
class VeloraController < ApplicationController
  layout "auth"
  skip_before_action :authenticate_user!
  skip_after_action :rewrite_currency

  def index
    @events = VeloraFeed.backfill
    @last_slot = @events.last&.dig(:slot) || VeloraFeed.current_slot
    # On the velora subdomain "/" is this page, so the CTA must point at the
    # demo's own host; everywhere else a relative link to the dashboard works.
    @demo_url = request.host.start_with?("velora.") ? "https://#{ENV.fetch('APP_HOST', 'growcentric-demo.ondigitalocean.app')}" : root_path
  end

  def feed
    events = VeloraFeed.since(params[:after].to_i)
    render json: { last_slot: events.last&.dig(:slot) || params[:after].to_i, events: events }
  end
end
