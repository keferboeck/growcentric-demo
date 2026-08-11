class CampaignsController < ApplicationController
  def index
    @campaigns = Campaign.order(spend_30d_cents: :desc)
    @shifts = BudgetShift.includes(:from_campaign, :to_campaign).order(:status, created_at: :desc)
    @ab_tests = AbTest.includes(:campaign).order(status: :desc, significance: :desc)
    @total_budget = @campaigns.sum(&:monthly_budget_cents)
    @total_spend = @campaigns.sum(&:spend_30d_cents)
    @total_revenue = @campaigns.sum(&:revenue_30d_cents)
    @blended_roas = @total_revenue.to_f / @total_spend
    @blended_poas = @campaigns.sum { |c| c.poas * c.spend_30d_cents } / @total_spend
    @auto_share = @campaigns.count(&:auto_managed) * 100 / @campaigns.size
  end
end
