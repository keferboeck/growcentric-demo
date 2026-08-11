class PricePositionController < ApplicationController
  def index
    @products = filter_products(Product.includes(:brand, category: :department))
                .order(:market_min_delta_pct).to_a
    @cheapest = @products.select { |p| p.market_min_delta_pct <= 0 }
    @premium_ok = @products.select { |p| p.market_min_delta_pct.positive? && p.visibility_score >= 65 }
    @losing = @products.select { |p| p.market_min_delta_pct > 10 }
    @avg_visibility = @products.sum(&:visibility_score) / [@products.size, 1].max

    @undermarketed = @products.select { |p| p.pageviews_30d >= 5_000 && p.monthly_ad_spend_cents < 500_00 && p.units_sold >= 60 }
                              .sort_by { |p| -p.pageviews_30d }

    presence_products = Product.where(id: ChannelPresence.select(:product_id))
                               .where(id: @products.map(&:id)).includes(:brand)
    presences = ChannelPresence.includes(:competitor).group_by(&:product_id)
    @matrix = presence_products.map do |product|
      cells = ChannelPresence::CHANNELS.index_with do |channel|
        (presences[product.id] || []).select { |cp| cp.channel == channel }
      end
      [product, cells]
    end
  end

  def self.verdict(product)
    if product.market_min_delta_pct <= 0
      product.visibility_score < 40 ? :cheapest_invisible : :cheapest
    elsif product.visibility_score >= 65 && product.trend_pct >= 0
      :premium_ok
    elsif product.market_min_delta_pct > 10
      :losing
    else
      :watch
    end
  end
end
