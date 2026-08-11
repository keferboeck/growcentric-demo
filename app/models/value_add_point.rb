class ValueAddPoint < ApplicationRecord
  scope :chronological, -> { order(:day) }

  def value_added_cents = actual_cents - baseline_cents
end
