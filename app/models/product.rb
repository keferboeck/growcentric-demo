class Product < ApplicationRecord
  belongs_to :brand
  belongs_to :category
  has_many :competitive_signals, dependent: :destroy
  has_many :price_points, dependent: :destroy

  scope :hidden_gems, -> { where(status: "hidden_gem").order(potential_score: :desc) }
  scope :losing, -> { where(status: "losing") }

  def price = price_cents / 100.0
  def monthly_revenue = monthly_revenue_cents / 100.0
  def monthly_ad_spend = monthly_ad_spend_cents / 100.0

  def department = category.department

  def price_tier
    if price_cents < 50_00 then "Entry"
    elsif price_cents <= 150_00 then "Mid"
    else "Premium"
    end
  end

  def season_label = { "all_season" => "All-season", "summer" => "Summer", "winter" => "Winter" }.fetch(season, season)
end
