class PricePoint < ApplicationRecord
  belongs_to :product

  scope :chronological, -> { order(:day) }
end
