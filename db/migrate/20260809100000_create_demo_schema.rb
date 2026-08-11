class CreateDemoSchema < ActiveRecord::Migration[7.1]
  def change
    create_table :brands do |t|
      t.string :name, null: false
      t.timestamps
    end

    create_table :categories do |t|
      t.string :name, null: false
      t.timestamps
    end

    create_table :products do |t|
      t.references :brand, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true
      t.string :name, null: false
      t.string :sku, null: false
      t.integer :price_cents, null: false
      t.integer :monthly_revenue_cents, null: false, default: 0
      t.integer :monthly_ad_spend_cents, null: false, default: 0
      t.integer :units_sold, null: false, default: 0
      t.integer :potential_score, null: false, default: 0   # 0..100 hidden-potential signal
      t.integer :competitive_score, null: false, default: 0 # -100..100 relative value vs market
      t.string :status, null: false, default: "steady"      # hidden_gem / bestseller / losing / steady
      t.decimal :trend_pct, precision: 6, scale: 1, null: false, default: 0
      t.timestamps
    end

    create_table :competitors do |t|
      t.string :name, null: false
      t.string :domain, null: false
      t.boolean :sponsored, null: false, default: false
      t.boolean :pinned, null: false, default: false
      t.string :discovery_source, null: false, default: "google_shopping" # google_shopping / manual
      t.string :level, null: false, default: "product"                    # industry / brand / product
      t.integer :product_overlap, null: false, default: 0
      t.integer :threat_score, null: false, default: 0 # 0..100
      t.timestamps
    end

    create_table :competitive_signals do |t|
      t.references :product, null: false, foreign_key: true
      t.references :competitor, null: false, foreign_key: true
      t.string :dimension, null: false # price / shipping / quantity / bundle
      t.string :position, null: false  # better / worse / equal
      t.decimal :delta_pct, precision: 6, scale: 1, null: false, default: 0
      t.datetime :detected_at, null: false
      t.timestamps
    end

    create_table :recommendations do |t|
      t.string :kind, null: false # invest / pull_back / attention / corrective
      t.string :title, null: false
      t.text :body, null: false
      t.string :target, null: false # human-readable target: product / brand / category name
      t.integer :impact_cents, null: false, default: 0 # projected monthly impact
      t.integer :confidence, null: false, default: 0   # 0..100
      t.timestamps
    end

    create_table :forecast_points do |t|
      t.date :day, null: false
      t.integer :actual_cents  # null for future days
      t.integer :forecast_cents, null: false
      t.integer :lower_cents, null: false
      t.integer :upper_cents, null: false
      t.timestamps
    end

    create_table :alerts do |t|
      t.string :severity, null: false # info / warning / critical
      t.string :kind, null: false     # early_warning / market_shift / opportunity
      t.string :title, null: false
      t.text :body, null: false
      t.datetime :occurred_at, null: false
      t.timestamps
    end
  end
end
