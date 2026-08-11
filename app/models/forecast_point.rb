class ForecastPoint < ApplicationRecord
  scope :chronological, -> { order(:day) }
end
