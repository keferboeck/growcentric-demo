class ShippingRule < ApplicationRecord
  belongs_to :competitor, optional: true # nil = the merchant

  scope :ours, -> { where(competitor_id: nil) }
  scope :theirs, -> { where.not(competitor_id: nil) }
end
