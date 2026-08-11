class AddPricingAndCampaigns < ActiveRecord::Migration[7.1]
  def change
    change_table :products, bulk: true do |t|
      t.integer :unit_cost_cents, null: false, default: 0
      t.integer :pageviews_30d, null: false, default: 0
      t.decimal :weeks_of_stock, precision: 5, scale: 1, null: false, default: 0
      t.integer :visibility_score, null: false, default: 0        # 0..100 share of voice on contested queries
      t.decimal :market_min_delta_pct, precision: 6, scale: 1     # our price vs cheapest competitor (derived index)
      t.decimal :market_median_delta_pct, precision: 6, scale: 1
      t.decimal :elasticity, precision: 4, scale: 1               # estimated price elasticity of demand
      t.boolean :dynamic_pricing, null: false, default: false
    end

    create_table :shipping_rules do |t|
      t.references :competitor, foreign_key: true # null = the merchant (Velora)
      t.string :rule_type, null: false            # flat / price_threshold / postcode_zone / radius / weight / size
      t.string :label, null: false
      t.string :detail, null: false
      t.integer :cost_cents
      t.datetime :captured_at, null: false
      t.timestamps
    end

    create_table :competitor_offers do |t|
      t.references :competitor, null: false, foreign_key: true
      t.string :offer_type, null: false # subscription / quantity / clearance
      t.string :title, null: false
      t.text :detail, null: false
      t.text :dynamics_note, null: false # how it changes the competitive dynamics
      t.datetime :detected_at, null: false
      t.timestamps
    end

    create_table :sale_events do |t|
      t.references :competitor, foreign_key: true # null = the merchant
      t.string :title, null: false
      t.string :season, null: false
      t.string :discount, null: false
      t.string :categories, null: false
      t.date :started_on, null: false
      t.date :ended_on
      t.text :note
      t.timestamps
    end

    create_table :campaigns do |t|
      t.string :name, null: false
      t.string :channel, null: false # google_shopping / meta / tiktok
      t.string :status, null: false, default: "active"
      t.string :target, null: false
      t.integer :monthly_budget_cents, null: false
      t.integer :spend_30d_cents, null: false, default: 0
      t.integer :revenue_30d_cents, null: false, default: 0
      t.decimal :margin_pct, precision: 5, scale: 1, null: false, default: 0
      t.boolean :auto_managed, null: false, default: false
      t.timestamps
    end

    create_table :budget_shifts do |t|
      t.references :from_campaign, null: false, foreign_key: { to_table: :campaigns }
      t.references :to_campaign, null: false, foreign_key: { to_table: :campaigns }
      t.integer :amount_cents, null: false
      t.text :reason, null: false
      t.string :status, null: false, default: "suggested" # suggested / auto_applied
      t.decimal :margin_factor, precision: 4, scale: 2
      t.decimal :conversion_factor, precision: 4, scale: 2
      t.decimal :inventory_factor, precision: 4, scale: 2
      t.decimal :competitive_factor, precision: 4, scale: 2
      t.decimal :projected_poas_gain, precision: 5, scale: 2
      t.datetime :applied_at
      t.timestamps
    end

    create_table :ab_tests do |t|
      t.references :campaign, null: false, foreign_key: true
      t.string :name, null: false
      t.string :variant_a, null: false
      t.string :variant_b, null: false
      t.string :metric, null: false
      t.decimal :a_value, precision: 8, scale: 2, null: false
      t.decimal :b_value, precision: 8, scale: 2, null: false
      t.decimal :significance, precision: 5, scale: 1, null: false # %
      t.string :status, null: false, default: "running" # running / complete
      t.string :winner # a / b
      t.boolean :auto_applied, null: false, default: false
      t.timestamps
    end

    create_table :channel_presences do |t|
      t.references :product, null: false, foreign_key: true
      t.references :competitor, foreign_key: true # null = the merchant
      t.string :channel, null: false # google_shopping / meta / tiktok
      t.datetime :detected_at, null: false
      t.timestamps
    end

    create_table :price_points do |t|
      t.references :product, null: false, foreign_key: true
      t.date :day, null: false
      t.integer :list_price_cents, null: false
      t.integer :avg_sold_price_cents
      t.decimal :market_min_index, precision: 5, scale: 3 # our price / cheapest competitor (derived, no raw prices stored)
      t.timestamps
    end

    create_table :sold_price_breakdowns do |t|
      t.references :product, null: false, foreign_key: true
      t.string :dimension, null: false # channel / campaign / segment
      t.string :label, null: false
      t.integer :avg_price_cents, null: false
      t.integer :orders, null: false
      t.timestamps
    end

    create_table :pricing_decisions do |t|
      t.references :product, null: false, foreign_key: true
      t.datetime :occurred_at, null: false
      t.integer :old_price_cents, null: false
      t.integer :new_price_cents, null: false
      t.string :trigger, null: false
      t.string :strategy, null: false # undercut / match / premium / dynamic
      t.string :guardrail
      t.string :status, null: false, default: "auto_applied" # auto_applied / pending_review
      t.timestamps
    end
  end
end
