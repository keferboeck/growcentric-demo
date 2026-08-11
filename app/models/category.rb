class Category < ApplicationRecord
  belongs_to :department, optional: true
  has_many :products, dependent: :destroy
end
