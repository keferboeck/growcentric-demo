class AbTest < ApplicationRecord
  belongs_to :campaign

  def uplift_pct = a_value.zero? ? 0 : (b_value - a_value) * 100.0 / a_value
end
