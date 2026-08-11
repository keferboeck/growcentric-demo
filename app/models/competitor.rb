class Competitor < ApplicationRecord
  has_many :competitive_signals, dependent: :destroy
  has_many :products, through: :competitive_signals

  scope :sponsored, -> { where(sponsored: true) }
  scope :organic, -> { where(sponsored: false) }
end
