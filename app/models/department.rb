class Department < ApplicationRecord
  has_many :categories, dependent: :nullify
  has_many :products, through: :categories
end
