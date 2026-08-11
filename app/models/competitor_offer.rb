class CompetitorOffer < ApplicationRecord
  belongs_to :competitor

  scope :recent, -> { order(detected_at: :desc) }
end
