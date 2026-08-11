class PricingDecision < ApplicationRecord
  belongs_to :product

  scope :recent, -> { order(occurred_at: :desc) }
end
