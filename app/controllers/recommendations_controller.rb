class RecommendationsController < ApplicationController
  def index
    @grouped = Recommendation.by_impact.group_by(&:kind)
    @total_impact_cents = Recommendation.sum(:impact_cents)
  end
end
