class Recommendation < ApplicationRecord
  KINDS = %w[invest pull_back attention corrective].freeze

  scope :by_impact, -> { order(impact_cents: :desc) }

  def impact = impact_cents / 100.0
end
