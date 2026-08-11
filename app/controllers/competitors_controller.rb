class CompetitorsController < ApplicationController
  def index
    @competitors = Competitor.order(threat_score: :desc)
    @signals = CompetitiveSignal.includes(:product, :competitor).recent.limit(12)
    @sponsored_count = Competitor.sponsored.count
    @pinned_count = Competitor.where(pinned: true).count
    @worse_signals = CompetitiveSignal.where(position: "worse").count
    @better_signals = CompetitiveSignal.where(position: "better").count
  end
end
