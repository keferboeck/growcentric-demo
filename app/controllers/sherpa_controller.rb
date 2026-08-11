class SherpaController < ApplicationController
  def index
    @pending_decisions = PricingDecision.where(status: "pending_review").includes(:product).recent
    @suggested_shifts = BudgetShift.where(status: "suggested").count
    @overnight_signals = CompetitiveSignal.where("detected_at > ?", 24.hours.ago).count
    @auto_repriced = PricingDecision.where(status: "auto_applied").where("occurred_at > ?", 24.hours.ago).count
  end
end
