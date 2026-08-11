class CompetitiveSignal < ApplicationRecord
  belongs_to :product
  belongs_to :competitor

  scope :recent, -> { order(detected_at: :desc) }
end
