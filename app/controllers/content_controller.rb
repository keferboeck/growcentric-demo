class ContentController < ApplicationController
  def catalog
    @products = filter_products(Product.includes(:brand, category: :department)).order(:name).to_a
    pending_ids = PricingDecision.where(status: "pending_review").pluck(:product_id)
    @rows = @products.map do |product|
      status =
        if product.name.include?("Storm Shell") then :missing_en
        elsif pending_ids.include?(product.id) then :draft
        elsif product.name.include?("Gravel Tyre") then :outdated
        else :up_to_date
        end
      seo = product.name.include?("Saddle Pack") ? :testing : :ok
      updated = ((product.id * 7) % 12) + 1
      [product, status, seo, updated]
    end
    @up_to_date = @rows.count { |r| r[1] == :up_to_date }
    @drafts = @rows.count { |r| r[1] == :draft }
    @needs_work = @rows.count { |r| %i[outdated missing_en].include?(r[1]) }
  end

  def queue
  end

  def experiments
  end
end
