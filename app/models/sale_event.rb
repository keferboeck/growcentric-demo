class SaleEvent < ApplicationRecord
  belongs_to :competitor, optional: true # nil = the merchant
end
