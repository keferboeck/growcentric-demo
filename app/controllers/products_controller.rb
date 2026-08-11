class ProductsController < ApplicationController
  def index
    @products = filter_products(Product.includes(:brand, category: :department))
                .order(potential_score: :desc).to_a
    @hidden_gems = @products.select { |p| p.status == "hidden_gem" }
    @untapped_cents = @hidden_gems.sum(&:monthly_revenue_cents)
    @avg_potential = @hidden_gems.sum(&:potential_score) / [@hidden_gems.size, 1].max
    @catalog_avg = @products.sum(&:potential_score) / [@products.size, 1].max

    total = @products.sum(&:monthly_revenue_cents)
    @rollups = {
      "By department" => rollup(@products, total) { |p| p.category.department.name },
      "By category"   => rollup(@products, total) { |p| p.category.name },
      "By brand"      => rollup(@products, total) { |p| p.brand.name }
    }
  end

  private

  def rollup(products, total_cents, &group_key)
    products.group_by(&group_key).map do |name, group|
      revenue = group.sum(&:monthly_revenue_cents)
      {
        name: name,
        revenue: revenue,
        share: total_cents.zero? ? 0 : revenue * 100.0 / total_cents,
        potential: group.sum(&:potential_score) / group.size,
        gems: group.count { |p| p.status == "hidden_gem" },
        count: group.size
      }
    end.sort_by { |row| -row[:revenue] }
  end
end
