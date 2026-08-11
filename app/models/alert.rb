class Alert < ApplicationRecord
  scope :recent, -> { order(occurred_at: :desc) }
end
