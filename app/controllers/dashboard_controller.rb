class DashboardController < ApplicationController
  def index
    @revenue_30d_cents = ForecastPoint.where(day: 29.days.ago.to_date..Date.current).sum(:actual_cents)
    @prev_30d_cents = ForecastPoint.where(day: 59.days.ago.to_date..30.days.ago.to_date).sum(:actual_cents)
    @forecast_30d_cents = ForecastPoint.where(day: Date.current + 1..Date.current + 30).sum(:forecast_cents)
    @hidden_gems = Product.hidden_gems
    @sponsored_competitors = Competitor.sponsored.count
    @competitor_count = Competitor.count
    @alerts = Alert.recent.limit(4)
    @recommendations = Recommendation.by_impact.limit(3)
    @forecast_points = ForecastPoint.chronological.where(day: 59.days.ago.to_date..Date.current + 30)
    @spark_points = ForecastPoint.chronological.where(day: 83.days.ago.to_date..Date.current)
                                 .pluck(:actual_cents).compact.each_slice(7).map { |w| w.sum / w.size }

    value_points = ValueAddPoint.chronological.to_a
    @value_added_cents = value_points.sum(&:value_added_cents)
    live = value_points.select { |p| p.value_added_cents.positive? }
    @value_share_pct = @value_added_cents * 100.0 / live.sum(&:baseline_cents)
    @value_live_days = live.size
    @value_weekly = value_points.group_by { |p| p.day.beginning_of_week }.sort
                                .select { |_week, pts| pts.size == 7 }
                                .map { |week, pts| { week: week, actual: pts.sum(&:actual_cents), baseline: pts.sum(&:baseline_cents) } }
    @value_breakdown = [
      ["Repricing engine", 0.40], ["Budget reallocation", 0.33],
      ["Hidden-gem campaigns", 0.17], ["Avoided decline", 0.10]
    ].map { |label, share| [label, (@value_added_cents * share).round] }

    @matrix_products = Product.includes(:brand).to_a
  end
end
