# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2026_08_11_081049) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "ab_tests", force: :cascade do |t|
    t.bigint "campaign_id", null: false
    t.string "name", null: false
    t.string "variant_a", null: false
    t.string "variant_b", null: false
    t.string "metric", null: false
    t.decimal "a_value", precision: 8, scale: 2, null: false
    t.decimal "b_value", precision: 8, scale: 2, null: false
    t.decimal "significance", precision: 5, scale: 1, null: false
    t.string "status", default: "running", null: false
    t.string "winner"
    t.boolean "auto_applied", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["campaign_id"], name: "index_ab_tests_on_campaign_id"
  end

  create_table "alerts", force: :cascade do |t|
    t.string "severity", null: false
    t.string "kind", null: false
    t.string "title", null: false
    t.text "body", null: false
    t.datetime "occurred_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "brands", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "budget_shifts", force: :cascade do |t|
    t.bigint "from_campaign_id", null: false
    t.bigint "to_campaign_id", null: false
    t.integer "amount_cents", null: false
    t.text "reason", null: false
    t.string "status", default: "suggested", null: false
    t.decimal "margin_factor", precision: 4, scale: 2
    t.decimal "conversion_factor", precision: 4, scale: 2
    t.decimal "inventory_factor", precision: 4, scale: 2
    t.decimal "competitive_factor", precision: 4, scale: 2
    t.decimal "projected_poas_gain", precision: 5, scale: 2
    t.datetime "applied_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["from_campaign_id"], name: "index_budget_shifts_on_from_campaign_id"
    t.index ["to_campaign_id"], name: "index_budget_shifts_on_to_campaign_id"
  end

  create_table "campaigns", force: :cascade do |t|
    t.string "name", null: false
    t.string "channel", null: false
    t.string "status", default: "active", null: false
    t.string "target", null: false
    t.integer "monthly_budget_cents", null: false
    t.integer "spend_30d_cents", default: 0, null: false
    t.integer "revenue_30d_cents", default: 0, null: false
    t.decimal "margin_pct", precision: 5, scale: 1, default: "0.0", null: false
    t.boolean "auto_managed", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "categories", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "department_id"
    t.index ["department_id"], name: "index_categories_on_department_id"
  end

  create_table "channel_presences", force: :cascade do |t|
    t.bigint "product_id", null: false
    t.bigint "competitor_id"
    t.string "channel", null: false
    t.datetime "detected_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["competitor_id"], name: "index_channel_presences_on_competitor_id"
    t.index ["product_id"], name: "index_channel_presences_on_product_id"
  end

  create_table "competitive_signals", force: :cascade do |t|
    t.bigint "product_id", null: false
    t.bigint "competitor_id", null: false
    t.string "dimension", null: false
    t.string "position", null: false
    t.decimal "delta_pct", precision: 6, scale: 1, default: "0.0", null: false
    t.datetime "detected_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["competitor_id"], name: "index_competitive_signals_on_competitor_id"
    t.index ["product_id"], name: "index_competitive_signals_on_product_id"
  end

  create_table "competitor_offers", force: :cascade do |t|
    t.bigint "competitor_id", null: false
    t.string "offer_type", null: false
    t.string "title", null: false
    t.text "detail", null: false
    t.text "dynamics_note", null: false
    t.datetime "detected_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["competitor_id"], name: "index_competitor_offers_on_competitor_id"
  end

  create_table "competitors", force: :cascade do |t|
    t.string "name", null: false
    t.string "domain", null: false
    t.boolean "sponsored", default: false, null: false
    t.boolean "pinned", default: false, null: false
    t.string "discovery_source", default: "google_shopping", null: false
    t.string "level", default: "product", null: false
    t.integer "product_overlap", default: 0, null: false
    t.integer "threat_score", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "departments", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "forecast_points", force: :cascade do |t|
    t.date "day", null: false
    t.integer "actual_cents"
    t.integer "forecast_cents", null: false
    t.integer "lower_cents", null: false
    t.integer "upper_cents", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "price_points", force: :cascade do |t|
    t.bigint "product_id", null: false
    t.date "day", null: false
    t.integer "list_price_cents", null: false
    t.integer "avg_sold_price_cents"
    t.decimal "market_min_index", precision: 5, scale: 3
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_price_points_on_product_id"
  end

  create_table "pricing_decisions", force: :cascade do |t|
    t.bigint "product_id", null: false
    t.datetime "occurred_at", null: false
    t.integer "old_price_cents", null: false
    t.integer "new_price_cents", null: false
    t.string "trigger", null: false
    t.string "strategy", null: false
    t.string "guardrail"
    t.string "status", default: "auto_applied", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_pricing_decisions_on_product_id"
  end

  create_table "products", force: :cascade do |t|
    t.bigint "brand_id", null: false
    t.bigint "category_id", null: false
    t.string "name", null: false
    t.string "sku", null: false
    t.integer "price_cents", null: false
    t.integer "monthly_revenue_cents", default: 0, null: false
    t.integer "monthly_ad_spend_cents", default: 0, null: false
    t.integer "units_sold", default: 0, null: false
    t.integer "potential_score", default: 0, null: false
    t.integer "competitive_score", default: 0, null: false
    t.string "status", default: "steady", null: false
    t.decimal "trend_pct", precision: 6, scale: 1, default: "0.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "unit_cost_cents", default: 0, null: false
    t.integer "pageviews_30d", default: 0, null: false
    t.decimal "weeks_of_stock", precision: 5, scale: 1, default: "0.0", null: false
    t.integer "visibility_score", default: 0, null: false
    t.decimal "market_min_delta_pct", precision: 6, scale: 1
    t.decimal "market_median_delta_pct", precision: 6, scale: 1
    t.decimal "elasticity", precision: 4, scale: 1
    t.boolean "dynamic_pricing", default: false, null: false
    t.string "season", default: "all_season", null: false
    t.index ["brand_id"], name: "index_products_on_brand_id"
    t.index ["category_id"], name: "index_products_on_category_id"
  end

  create_table "recommendations", force: :cascade do |t|
    t.string "kind", null: false
    t.string "title", null: false
    t.text "body", null: false
    t.string "target", null: false
    t.integer "impact_cents", default: 0, null: false
    t.integer "confidence", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sale_events", force: :cascade do |t|
    t.bigint "competitor_id"
    t.string "title", null: false
    t.string "season", null: false
    t.string "discount", null: false
    t.string "categories", null: false
    t.date "started_on", null: false
    t.date "ended_on"
    t.text "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["competitor_id"], name: "index_sale_events_on_competitor_id"
  end

  create_table "shipping_rules", force: :cascade do |t|
    t.bigint "competitor_id"
    t.string "rule_type", null: false
    t.string "label", null: false
    t.string "detail", null: false
    t.integer "cost_cents"
    t.datetime "captured_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["competitor_id"], name: "index_shipping_rules_on_competitor_id"
  end

  create_table "sold_price_breakdowns", force: :cascade do |t|
    t.bigint "product_id", null: false
    t.string "dimension", null: false
    t.string "label", null: false
    t.integer "avg_price_cents", null: false
    t.integer "orders", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_sold_price_breakdowns_on_product_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "value_add_points", force: :cascade do |t|
    t.date "day", null: false
    t.integer "actual_cents", null: false
    t.integer "baseline_cents", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "ab_tests", "campaigns"
  add_foreign_key "budget_shifts", "campaigns", column: "from_campaign_id"
  add_foreign_key "budget_shifts", "campaigns", column: "to_campaign_id"
  add_foreign_key "categories", "departments"
  add_foreign_key "channel_presences", "competitors"
  add_foreign_key "channel_presences", "products"
  add_foreign_key "competitive_signals", "competitors"
  add_foreign_key "competitive_signals", "products"
  add_foreign_key "competitor_offers", "competitors"
  add_foreign_key "price_points", "products"
  add_foreign_key "pricing_decisions", "products"
  add_foreign_key "products", "brands"
  add_foreign_key "products", "categories"
  add_foreign_key "sale_events", "competitors"
  add_foreign_key "shipping_rules", "competitors"
  add_foreign_key "sold_price_breakdowns", "products"
end
