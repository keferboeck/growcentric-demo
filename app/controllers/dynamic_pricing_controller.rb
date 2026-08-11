class DynamicPricingController < ApplicationController
  def index
    @beacon = Product.find_by!(name: "LumenRide Beacon 1200 Front Light")
    @price_points = @beacon.price_points.chronological
    @breakdowns = SoldPriceBreakdown.where(product: @beacon).group_by(&:dimension)
    @decisions = PricingDecision.includes(:product).recent
    @dynamic_products = Product.where(dynamic_pricing: true).order(:name)

    @win_rate = Product.where("market_min_delta_pct <= 0").count * 100 / Product.count
    @changes_7d = 23
    @auto_changes_7d = 18

    # Elasticity optimum per the playbook: P* = (C × ε) / (ε + 1)
    @elasticity_rows = @dynamic_products.map do |p|
      optimal = p.unit_cost_cents * p.elasticity / (p.elasticity + 1)
      [p, optimal.round]
    end
  end
end
