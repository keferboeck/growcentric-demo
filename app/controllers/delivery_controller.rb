class DeliveryController < ApplicationController
  def index
    @our_rules = ShippingRule.ours.order(:id)
    @their_rules = ShippingRule.theirs.includes(:competitor).order(:competitor_id, :id).group_by(&:competitor)
    @offers = CompetitorOffer.includes(:competitor).recent
    @sale_events = SaleEvent.includes(:competitor).order(started_on: :desc)
    @subscription_count = CompetitorOffer.where(offer_type: "subscription").count
    @rules_captured = ShippingRule.theirs.count
    @lower_thresholds = 2 # competitors with a free-shipping threshold below ours (€79): Radquartier €50, Lichtblick €29
  end
end
