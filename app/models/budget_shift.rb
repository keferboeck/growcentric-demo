class BudgetShift < ApplicationRecord
  belongs_to :from_campaign, class_name: "Campaign"
  belongs_to :to_campaign, class_name: "Campaign"
end
