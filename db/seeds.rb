# Demo data for GrowCentric product teaser screenshots.
# The merchant: "Velora Cycling Supply", a fictional Vienna-based Shopify shop.
# All brands, competitors and domains are invented.

# Login for the demo wall (Devise). Password can be overridden via env.
demo_user = User.find_or_initialize_by(email: "georg@keferboeck.com")
demo_user.password = ENV.fetch("GROWCENTRIC_DEMO_PASSWORD", "Gr0wCentr1c!!x")
demo_user.save!

ValueAddPoint.delete_all
PricingDecision.delete_all
SoldPriceBreakdown.delete_all
PricePoint.delete_all
ChannelPresence.delete_all
AbTest.delete_all
BudgetShift.delete_all
Campaign.delete_all
SaleEvent.delete_all
CompetitorOffer.delete_all
ShippingRule.delete_all
CompetitiveSignal.delete_all
Product.delete_all
Brand.delete_all
Category.delete_all
Department.delete_all
Competitor.delete_all
Recommendation.delete_all
ForecastPoint.delete_all
Alert.delete_all

rng = Random.new(42)

brands = %w[NordPeak TrailForge AlpenGlow GripWorks Cadenza LumenRide Veloce].index_with do |name|
  Brand.create!(name: name)
end

DEPARTMENTS = {
  "Gear & Equipment" => ["Helmets", "Lights & Electronics", "Bikepacking Bags"],
  "Workshop & Parts" => ["Tools & Maintenance", "Components"],
  "Apparel"          => ["Apparel"]
}

categories = {}
DEPARTMENTS.each do |dept_name, category_names|
  department = Department.create!(name: dept_name)
  category_names.each do |name|
    categories[name] = Category.create!(name: name, department: department)
  end
end

PRODUCTS = [
  # name, brand, category, price €, revenue €/mo, ad spend €/mo, units, potential, competitive, status, trend %
  ["NordPeak Crest MIPS Helmet",        "NordPeak",  "Helmets",               189.90, 28_480, 3_200, 150,  38,  12, "bestseller",  +4.2],
  ["NordPeak Vista Commuter Helmet",    "NordPeak",  "Helmets",                89.90, 12_580, 1_450, 140,  44,  -8, "steady",      +1.1],
  ["LumenRide Beacon 1200 Front Light", "LumenRide", "Lights & Electronics",  114.90, 18_380, 2_900, 160,  41, -34, "losing",     -12.6],
  ["LumenRide Pulse Rear Radar",        "LumenRide", "Lights & Electronics",  199.00, 21_890, 2_640, 110,  52, -21, "losing",      -8.9],
  ["LumenRide Orbit Wheel Lights",      "LumenRide", "Lights & Electronics",   34.90,  2_440,   180,  70,  87,  41, "hidden_gem", +22.4],
  ["TrailForge Saddle Pack 14L",        "TrailForge","Bikepacking Bags",      129.00,  9_030,   610,  70,  91,  48, "hidden_gem", +31.0],
  ["TrailForge Frame Bag 5L",           "TrailForge","Bikepacking Bags",       79.00,  5_530,   420,  70,  84,  36, "hidden_gem", +18.7],
  ["TrailForge Bar Roll Harness",       "TrailForge","Bikepacking Bags",       94.00,  3_760,   350,  40,  78,  29, "hidden_gem", +14.2],
  ["GripWorks Torque Wrench Set",       "GripWorks", "Tools & Maintenance",    64.90,  7_140,   540, 110,  57,  22, "steady",      +3.8],
  ["GripWorks Chain Doctor Pro",        "GripWorks", "Tools & Maintenance",    29.90,  4_190,   380, 140,  73,  31, "hidden_gem", +11.9],
  ["AlpenGlow Merino Jersey",           "AlpenGlow", "Apparel",               119.00, 16_660,  2_260, 140,  35,   6, "bestseller",  +2.4],
  ["AlpenGlow Storm Shell Jacket",      "AlpenGlow", "Apparel",               219.00, 19_710,  2_840,  90,  31, -14, "steady",      -1.8],
  ["Cadenza Carbon Seatpost",           "Cadenza",   "Components",            159.00,  6_360,   720,  40,  49,  -4, "steady",      +0.9],
  ["Cadenza Ceramic Bottom Bracket",    "Cadenza",   "Components",            139.00,  4_170,   610,  30,  66,  18, "steady",      +6.3],
  ["Veloce Gravel Tyre 45c (Pair)",     "Veloce",    "Components",             94.00, 13_160,  1_980, 140,  46, -27, "losing",      -9.4],
  ["Veloce Tubeless Sealant 1L",        "Veloce",    "Tools & Maintenance",    24.90,  3_490,   210, 140,  81,  38, "hidden_gem", +16.5],
]

products = PRODUCTS.map do |name, brand, category, price, revenue, ad_spend, units, potential, competitive, status, trend|
  Product.create!(
    name: name,
    brand: brands.fetch(brand),
    category: categories.fetch(category),
    sku: "VCS-#{name.split.map { |w| w[0] }.join.upcase}-#{format('%03d', rng.rand(100..999))}",
    price_cents: (price * 100).round,
    monthly_revenue_cents: revenue * 100,
    monthly_ad_spend_cents: ad_spend * 100,
    units_sold: units,
    potential_score: potential,
    competitive_score: competitive,
    status: status,
    trend_pct: trend
  )
end

COMPETITORS = [
  # name, domain, sponsored, pinned, source, level, overlap, threat
  ["Radquartier",     "radquartier.at",   true,  true,  "google_shopping", "industry", 214, 78],
  ["Bikeinsel",       "bikeinsel.de",     true,  true,  "google_shopping", "industry", 187, 74],
  ["Velodrom24",      "velodrom24.de",    true,  false, "google_shopping", "brand",     96, 61],
  ["Pedalwerk",       "pedalwerk.nl",     false, false, "google_shopping", "brand",     73, 42],
  ["Alpenrad Shop",   "alpenrad.shop",    true,  false, "google_shopping", "product",   41, 55],
  ["Gravelheld",      "gravelheld.de",    false, true,  "manual",          "product",   38, 47],
  ["Lichtblick Velo", "lichtblick-velo.de", true, false, "google_shopping", "product",  22, 66],
]

competitors = COMPETITORS.map do |name, domain, sponsored, pinned, source, level, overlap, threat|
  Competitor.create!(
    name: name, domain: domain, sponsored: sponsored, pinned: pinned,
    discovery_source: source, level: level, product_overlap: overlap, threat_score: threat
  )
end

SIGNALS = [
  # product idx, competitor idx, dimension, position, delta %, days ago
  [2,  6, "price",    "worse",  -18.0, 0.2],
  [2,  0, "bundle",   "worse",  -11.0, 1.1],
  [3,  6, "price",    "worse",  -14.5, 0.4],
  [3,  1, "shipping", "worse",   -6.0, 2.3],
  [14, 2, "price",    "worse",  -12.0, 0.8],
  [14, 4, "quantity", "worse",   -9.0, 3.1],
  [5,  3, "price",    "better",  14.0, 1.6],
  [5,  5, "price",    "better",   9.5, 4.0],
  [6,  5, "price",    "better",  11.0, 2.8],
  [4,  4, "price",    "better",  17.0, 0.9],
  [9,  1, "price",    "better",   8.0, 5.2],
  [15, 2, "quantity", "better",  12.5, 1.9],
  [0,  0, "price",    "equal",    0.0, 2.1],
  [10, 1, "shipping", "better",   4.0, 6.4],
  [11, 0, "price",    "worse",   -7.5, 1.3],
]

SIGNALS.each do |p_idx, c_idx, dimension, position, delta, days_ago|
  CompetitiveSignal.create!(
    product: products[p_idx], competitor: competitors[c_idx],
    dimension: dimension, position: position, delta_pct: delta,
    detected_at: days_ago.days.ago
  )
end

RECOMMENDATIONS = [
  ["invest", "Push TrailForge bikepacking range",
   "TrailForge Saddle Pack 14L and Frame Bag 5L price 11–14% below every discovered competitor, with rising organic demand and near-zero ad spend. Shift budget here to capture the category before Radquartier starts sponsoring it.",
   "TrailForge · Bikepacking Bags", 6_800_00, 88],
  ["invest", "Sponsor LumenRide Orbit Wheel Lights",
   "Highest hidden-potential score in the catalog (87). You are 17% cheaper than Alpenrad Shop and nobody is sponsoring this product on Google Shopping. A cheap slot to own.",
   "LumenRide Orbit Wheel Lights", 2_100_00, 82],
  ["pull_back", "Stop ads on Beacon 1200 Front Light",
   "Lichtblick Velo undercuts you by 18% and runs sponsored placements on the same queries. Every click you buy converts worse each week. Pause spend until the pricing position is fixed.",
   "LumenRide Beacon 1200 Front Light", 2_900_00, 91],
  ["pull_back", "Reduce spend on Veloce Gravel Tyre 45c",
   "Velodrom24 moved to a 2-pair bundle 12% below your effective price. Your cost per conversion doubled in three weeks. Cut budget by half and monitor.",
   "Veloce Gravel Tyre 45c (Pair)", 1_400_00, 76],
  ["attention", "Storm Shell Jacket losing price position",
   "Radquartier dropped 7.5% below your price this week. Not yet critical; margin still allows a response. Decide between matching or repositioning on value.",
   "AlpenGlow Storm Shell Jacket", 900_00, 64],
  ["corrective", "Lights & Electronics trending into decline",
   "Forecast shows the category revenue dipping below plan within 5 weeks, driven by two losing SKUs. Reallocating the freed Beacon 1200 budget to Orbit Wheel Lights and the radar bundle offsets the projected decline.",
   "Lights & Electronics", 4_300_00, 79],
]

RECOMMENDATIONS.each do |kind, title, body, target, impact, confidence|
  Recommendation.create!(kind: kind, title: title, body: body, target: target,
                         impact_cents: impact, confidence: confidence)
end

# Forecast: 90 days of actuals, 60 days forward. Weekly seasonality + gentle growth,
# with the forward view flattening, enough to justify an early warning on one category.
base = 6_150.0
today = Date.current
(-89..60).each do |offset|
  day = today + offset
  t = offset + 89
  weekly = 1.0 + 0.09 * Math.sin((day.wday - 5) * Math::PI / 3.5)
  growth = 1.0 + 0.0022 * t
  level = base * weekly * growth

  actual = nil
  if offset <= 0
    noise = 1.0 + rng.rand(-0.04..0.04)
    actual = (level * noise * 100).round
  end

  spread = offset.positive? ? 0.05 + 0.0035 * offset : 0.04
  softening = offset.positive? ? 1.0 - 0.0009 * offset : 1.0
  forecast = level * softening

  ForecastPoint.create!(
    day: day,
    actual_cents: actual,
    forecast_cents: (forecast * 100).round,
    lower_cents: (forecast * (1 - spread) * 100).round,
    upper_cents: (forecast * (1 + spread) * 100).round
  )
end

ALERTS = [
  ["warning", "early_warning", "Lights & Electronics: decline forecast in 5 weeks",
   "Category revenue is projected to fall 14% below plan by mid-September, driven by Beacon 1200 and Pulse Rear Radar losing price position. Corrective actions are ready for review.", 0.15],
  ["critical", "market_shift", "Lichtblick Velo undercut Beacon 1200 by 18%",
   "New sponsored competitor detected on 9 of your core light queries. They are actively bidding on the same audience.", 0.3],
  ["info", "opportunity", "Nobody sponsors Orbit Wheel Lights queries",
   "Demand for wheel lights is up 22% this month and no competitor runs sponsored placements. You hold the best price in the discovered set.", 1.2],
  ["warning", "market_shift", "Velodrom24 switched Gravel Tyres to bundle pricing",
   "A 2-pair bundle now lands 12% under your effective single-pair price on comparison queries.", 2.4],
  ["info", "opportunity", "TrailForge demand rising in DE and NL",
   "Search interest for saddle packs is up for the fourth consecutive week. Your prices lead the discovered competitor set by 11–14%.", 3.6],
]

ALERTS.each do |severity, kind, title, body, days_ago|
  Alert.create!(severity: severity, kind: kind, title: title, body: body, occurred_at: days_ago.days.ago)
end

puts "Seeded: #{Product.count} products, #{Competitor.count} competitors, #{CompetitiveSignal.count} signals, " \
     "#{Recommendation.count} recommendations, #{ForecastPoint.count} forecast points, #{Alert.count} alerts."

# ---------------------------------------------------------------------------
# Pricing, campaigns, delivery & channel intelligence (second demo iteration)
# ---------------------------------------------------------------------------

# Per-product economics: cost %, views/30d, weeks of stock, visibility score,
# delta vs market min / median (derived indices), elasticity, dynamic pricing on/off
EXTRAS = [
  [55, 5_200,  4.2, 82,  +6.0,  -2.0, -1.6, true],  # Crest MIPS Helmet
  [55, 3_100,  5.8, 61,  +2.0,  -3.5, -2.1, false], # Vista Commuter Helmet
  [52, 4_700,  8.9, 38, +18.0,  +9.5, -2.8, true],  # Beacon 1200 Front Light
  [50, 3_900,  7.4, 45, +14.5,  +6.0, -2.4, true],  # Pulse Rear Radar
  [45, 8_400,  3.1, 22, -14.5, -22.0, -1.8, false], # Orbit Wheel Lights
  [48, 6_100,  4.8, 34, -11.0, -16.0, -1.9, false], # Saddle Pack 14L
  [48, 4_400,  5.2, 31,  -9.5, -14.0, -2.0, false], # Frame Bag 5L
  [48, 2_600,  6.0, 28,  -8.0, -12.5, -2.2, false], # Bar Roll Harness
  [50, 3_300,  9.6, 55,  +1.5,  -4.0, -2.6, true],  # Torque Wrench Set
  [42, 6_900,  5.4, 33,  -6.0, -10.0, -2.3, false], # Chain Doctor Pro
  [46, 4_800,  6.2, 76,  +4.0,  -1.5, -1.7, true],  # Merino Jersey
  [48, 3_700, 11.8, 58,  +7.5,  +3.0, -2.0, true],  # Storm Shell Jacket
  [52, 1_900,  7.7, 49,  +2.5,  -2.0, -2.4, false], # Carbon Seatpost
  [50, 2_200,  6.5, 42,  -3.5,  -7.0, -2.2, false], # Ceramic Bottom Bracket
  [58, 5_600, 12.4, 52, +12.0,  +5.5, -3.1, true],  # Gravel Tyre 45c
  [40, 5_900,  4.6, 36,  -7.5, -11.0, -2.1, false]  # Tubeless Sealant 1L
]

products.each_with_index do |product, i|
  cost_pct, views, wos, vis, min_d, med_d, elasticity, dynamic = EXTRAS[i]
  product.update!(
    unit_cost_cents: (product.price_cents * cost_pct / 100.0).round,
    pageviews_30d: views,
    weeks_of_stock: wos,
    visibility_score: vis,
    market_min_delta_pct: min_d,
    market_median_delta_pct: med_d,
    elasticity: elasticity,
    dynamic_pricing: dynamic
  )
end

by_name = competitors.index_by(&:name)

# --- Shipping & delivery tariffs (auto-captured by the crawler) -------------
SHIPPING_RULES = [
  # competitor (nil = us), rule_type, label, detail, cost €, captured days ago
  [nil, "flat",            "Standard AT/DE",     "€4,90 flat · 2–3 working days",                          4.90, 0.5],
  [nil, "price_threshold", "Free shipping",      "Free on all orders over €79",                            0.00, 0.5],
  [nil, "radius",          "Vienna courier",     "Same-day within 15 km of 1070 Wien",                     6.90, 0.5],
  [nil, "postcode_zone",   "Zone West",          "PLZ 6000–6999 (Tirol/Vlbg): +1 day, surcharge",          5.90, 0.5],
  [nil, "weight",          "Bulky & heavy",      "Over 5 kg or 120 cm (wheelsets, frames)",               14.90, 0.5],
  ["Radquartier",     "price_threshold", "Free over €50",        "Free shipping threshold dropped from €75 → €50",       0.00, 2.1],
  ["Radquartier",     "weight",          "Bulky",                "€12,90 over 10 kg",                                   12.90, 2.1],
  ["Bikeinsel",       "weight",          "Weight tiers",         "€3,95 <2 kg · €6,95 2–10 kg · €19 bulky",              3.95, 1.3],
  ["Velodrom24",      "flat",            "Flat DE",              "€2,95 flat, cheapest base rate in the set",            2.95, 0.8],
  ["Velodrom24",      "size",            "Oversize",             "€9,95 over 60 cm parcel edge",                         9.95, 0.8],
  ["Lichtblick Velo", "price_threshold", "Free over €29",        "Aggressive free-shipping threshold on lights",         0.00, 0.3],
  ["Pedalwerk",       "postcode_zone",   "NL/BE only",           "€6,95 · does not deliver to AT, no threat there",     6.95, 4.2],
  ["Alpenrad Shop",   "radius",          "Local free delivery",  "Free within 25 km of Rosenheim, else €5,90",           0.00, 3.0]
]

SHIPPING_RULES.each do |comp, rule_type, label, detail, cost, days_ago|
  ShippingRule.create!(
    competitor: comp && by_name.fetch(comp),
    rule_type: rule_type, label: label, detail: detail,
    cost_cents: (cost * 100).round, captured_at: days_ago.days.ago
  )
end

# --- Competitor offers: subscriptions, quantity deals, clearance ------------
OFFERS = [
  ["Radquartier", "subscription", "Radquartier PLUS · €39/year",
   "Free shipping on everything, 5% member prices, early access to sales.",
   "For PLUS members their effective price beats yours on 61 shared SKUs, even where your list price is lower.", 5.0],
  ["Bikeinsel", "subscription", "B-Club · €4,99/month",
   "Free shipping and free returns, monthly voucher.",
   "Neutralises your €79 free-shipping threshold for their subscriber base.", 12.0],
  ["Velodrom24", "quantity", "2-pair tyre bundle −12%",
   "Buy two pairs of gravel/road tyres, 12% off the pair price.",
   "Their bundle lands 12% under your single-pair price on comparison queries, the driver behind the Gravel Tyre losing position.", 2.4],
  ["Lichtblick Velo", "quantity", "Front + rear light set −15%",
   "Set discount across all front/rear combinations.",
   "Beats your Beacon 1200 + Pulse Radar bought separately by €38. Bundle pressure on your two losing SKUs.", 1.1],
  ["Alpenrad Shop", "clearance", "Helmet clearance −40%",
   "Last season's helmet models at up to −40%.",
   "Time-boxed pressure on Vista Commuter; your Crest MIPS (current model) is unaffected.", 6.5]
]

OFFERS.each do |comp, type, title, detail, note, days_ago|
  CompetitorOffer.create!(
    competitor: by_name.fetch(comp), offer_type: type, title: title,
    detail: detail, dynamics_note: note, detected_at: days_ago.days.ago
  )
end

# --- Season sales history ---------------------------------------------------
SALES = [
  ["Radquartier", "Season-end SALE", "Summer 2025", "−20% to −50%", "Apparel · Helmets",
   Date.new(2025, 8, 15), Date.new(2025, 9, 30),
   "Pulled your apparel revenue −18% during the window. Expect a repeat starting mid-August."],
  [nil, "Velora Season Finale", "Summer 2025", "−15% to −30%", "Apparel · Bags",
   Date.new(2025, 9, 1), Date.new(2025, 9, 28),
   "Cleared 82% of seasonal stock at a blended 41% margin."],
  ["Velodrom24", "Black Week", "November 2025", "−25%", "Components · Tools",
   Date.new(2025, 11, 24), Date.new(2025, 12, 1),
   "Short but deep: your components revenue dipped −11% that week."],
  ["Bikeinsel", "Winterschlussverkauf", "Winter 2025/26", "−30%", "Lights · Apparel",
   Date.new(2026, 1, 10), Date.new(2026, 2, 15),
   "Overlapped with your full-price lights strategy; the start of the Beacon 1200 decline."],
  ["Radquartier", "Season-end SALE", "Summer 2026 (expected)", "−20% to −50%", "Apparel · Helmets",
   Date.new(2026, 8, 15), nil,
   "Predicted from two prior years' pattern. Recommendation: pre-position your own clearance one week earlier."]
]

SALES.each do |comp, title, season, discount, cats, started, ended, note|
  SaleEvent.create!(
    competitor: comp && by_name.fetch(comp), title: title, season: season,
    discount: discount, categories: cats, started_on: started, ended_on: ended, note: note
  )
end

# --- Campaigns (the POAS story: high ROAS ≠ profitable) ---------------------
CAMPAIGNS = [
  # name, channel, status, target, budget €, spend €, revenue €, margin %, auto
  ["Shopping · Helmets (brand)",   "google_shopping", "active", "NordPeak · Helmets",        3_600, 3_450, 15_870, 45.0, true],
  ["Shopping · Lights core",       "google_shopping", "active", "LumenRide · Lights",        5_600, 5_540, 21_050, 20.0, true],
  ["Meta · Apparel lookalikes",    "meta",            "active", "AlpenGlow · Apparel",       2_800, 2_710,  8_940, 54.0, false],
  ["Shopping · Bikepacking",       "google_shopping", "active", "TrailForge · Bags",           800,   780,  4_840, 52.0, true],
  ["TikTok · Orbit UGC test",      "tiktok",          "testing", "LumenRide Orbit Lights",      600,   585,  2_110, 55.0, true],
  ["Meta · Retargeting all",       "meta",            "active", "All catalog",               1_900, 1_860,  7_250, 41.0, true],
  ["Shopping · Gravel tyres",      "google_shopping", "active", "Veloce · Tyres",            2_400, 2_350,  6_820, 24.0, false]
]

campaigns = CAMPAIGNS.map do |name, channel, status, target, budget, spend, revenue, margin, auto|
  Campaign.create!(
    name: name, channel: channel, status: status, target: target,
    monthly_budget_cents: budget * 100, spend_30d_cents: spend * 100,
    revenue_30d_cents: revenue * 100, margin_pct: margin, auto_managed: auto
  )
end
camp = campaigns.index_by(&:name)

# --- Budget shifts (allocator: Score = margin × conversion × inventory × competitive) --
BudgetShift.create!(
  from_campaign: camp["Shopping · Lights core"], to_campaign: camp["Shopping · Bikepacking"],
  amount_cents: 1_800_00, status: "auto_applied", applied_at: 2.days.ago,
  margin_factor: 1.40, conversion_factor: 1.30, inventory_factor: 1.10, competitive_factor: 1.20,
  projected_poas_gain: 0.94,
  reason: "Lights core runs POAS 0.76 (unprofitable despite 3.8× ROAS at 20% margin). Bikepacking runs POAS 3.22 with budget capped at €800 and impression share lost to budget 61%."
)
BudgetShift.create!(
  from_campaign: camp["Shopping · Gravel tyres"], to_campaign: camp["TikTok · Orbit UGC test"],
  amount_cents: 1_000_00, status: "suggested",
  margin_factor: 1.35, conversion_factor: 1.20, inventory_factor: 0.90, competitive_factor: 1.20,
  projected_poas_gain: 0.61,
  reason: "Gravel tyres POAS 0.70 while Velodrom24's bundle undercuts you (competitive factor 0.7 on the source). Orbit test converts at 55% margin with zero competitor ad presence."
)
BudgetShift.create!(
  from_campaign: camp["Shopping · Lights core"], to_campaign: camp["Meta · Retargeting all"],
  amount_cents: 700_00, status: "suggested",
  margin_factor: 1.15, conversion_factor: 1.25, inventory_factor: 1.00, competitive_factor: 1.05,
  projected_poas_gain: 0.28,
  reason: "Retargeting holds POAS 1.60 with room in frequency caps; incremental spend estimated to stay above 1.4."
)

# --- A/B tests --------------------------------------------------------------
AB_TESTS = [
  ["Shopping · Helmets (brand)", "Headline: price vs safety", "\"Ab €89,90\"", "\"MIPS-certified protection\"",
   "CTR %", 1.8, 2.6, 97.2, "complete", "b", true],
  ["Meta · Apparel lookalikes", "Creative: studio vs trail UGC", "Studio product shots", "Trail UGC video",
   "ROAS", 2.9, 3.6, 94.8, "complete", "b", true],
  ["Shopping · Bikepacking", "Landing: category vs bundle", "Category listing page", "Bikepacking bundle page",
   "CVR %", 3.1, 4.0, 96.1, "complete", "b", true],
  ["Shopping · Lights core", "Bid strategy: tROAS 380 vs 320", "tROAS 380%", "tROAS 320%",
   "POAS", 0.76, 0.92, 91.4, "running", nil, false],
  ["TikTok · Orbit UGC test", "Hook: commute vs festival", "\"Night commute safety\"", "\"Festival wheels\"",
   "CPA €", 12.40, 9.80, 88.9, "running", nil, false]
]

AB_TESTS.each do |campaign_name, name, va, vb, metric, a, b, sig, status, winner, auto|
  AbTest.create!(
    campaign: camp.fetch(campaign_name), name: name, variant_a: va, variant_b: vb,
    metric: metric, a_value: a, b_value: b, significance: sig,
    status: status, winner: winner, auto_applied: auto
  )
end

# --- Channel ad presence (who advertises what, where) -----------------------
PRESENCES = [
  # product idx, advertiser (nil = us), channel
  [0, nil, "google_shopping"], [0, "Radquartier", "google_shopping"], [0, "Bikeinsel", "google_shopping"],
  [0, nil, "meta"], [0, "Radquartier", "meta"],
  [2, nil, "google_shopping"], [2, "Lichtblick Velo", "google_shopping"], [2, "Radquartier", "google_shopping"],
  [2, "Lichtblick Velo", "meta"], [2, "Lichtblick Velo", "tiktok"],
  [3, nil, "google_shopping"], [3, "Lichtblick Velo", "google_shopping"], [3, "Lichtblick Velo", "tiktok"],
  [4, nil, "tiktok"],
  [5, nil, "google_shopping"],
  [11, nil, "google_shopping"], [11, "Radquartier", "google_shopping"], [11, "Radquartier", "meta"], [11, "Radquartier", "tiktok"],
  [14, nil, "google_shopping"], [14, "Velodrom24", "google_shopping"], [14, "Bikeinsel", "google_shopping"],
  [14, "Velodrom24", "meta"]
]

PRESENCES.each do |p_idx, comp, channel|
  ChannelPresence.create!(
    product: products[p_idx], competitor: comp && by_name.fetch(comp),
    channel: channel, detected_at: rng.rand(0.2..5.0).days.ago
  )
end

# --- Price development for the dynamic-pricing showcase (Beacon 1200) -------
beacon = products[2]
(-119..0).each do |offset|
  day = Date.current + offset
  list =
    if    offset < -70 then 119_90
    elsif offset < -25 then 114_90
    else                    109_90
    end
  index =
    if    offset < -84 then 0.98 + rng.rand(-0.01..0.01)   # we were cheapest
    elsif offset < -70 then 1.10 + rng.rand(-0.01..0.01)   # Lichtblick arrives
    elsif offset < -25 then 1.05 + rng.rand(-0.015..0.015) # our first step down
    elsif offset < -8  then 1.08 + rng.rand(-0.01..0.01)
    else                    1.18 + rng.rand(-0.01..0.01)   # their −18% move
    end
  sold = offset % 3 == 1 ? nil : (list * (1 - rng.rand(0.02..0.07))).round
  PricePoint.create!(
    product: beacon, day: day, list_price_cents: list,
    avg_sold_price_cents: sold, market_min_index: index.round(3)
  )
end

# --- Prices actually sold at, by channel / campaign / customer segment ------
BREAKDOWNS = [
  ["channel",  "Google Shopping",        109_12, 214],
  ["channel",  "Meta retargeting",       112_40,  88],
  ["channel",  "Organic & direct",       114_90, 156],
  ["campaign", "Shopping · Lights core", 108_60, 190],
  ["campaign", "Meta · Retargeting",     111_20,  74],
  ["campaign", "No campaign",            114_90, 194],
  ["segment",  "New visitors",           113_80, 122],
  ["segment",  "Returning (2+ visits)",  109_40, 208],
  ["segment",  "Newsletter subscribers", 107_90,  68]
]

BREAKDOWNS.each do |dimension, label, price, orders|
  SoldPriceBreakdown.create!(product: beacon, dimension: dimension, label: label,
                             avg_price_cents: price, orders: orders)
end

# --- Pricing engine decision log --------------------------------------------
DECISIONS = [
  [2,  26, 114_90, 109_90, "Lichtblick moved −18% on core light queries", "dynamic",
   "Max daily change −5% applied", "auto_applied"],
  [2,   2, 109_90,  99_90, "Sustained undercut + overstock (8,9 weeks)", "dynamic",
   "Floor check passed (cost + 25% = €89,90)", "pending_review"],
  [14, 19,  94_00,  89_90, "Velodrom24 bundle → effective −12%", "match",
   "Psychological rounding to ,90", "auto_applied"],
  [11, 31, 219_00, 209_90, "Overstock 11,8 weeks → weeks-of-stock ratio >2", "undercut",
   "Max daily change −5% applied", "auto_applied"],
  [0,  52, 189_90, 194_90, "Market leader: visibility 82, conversion stable, ε −1,6", "premium",
   "KVI ceiling €199,00 respected", "auto_applied"],
  [15, 44,  24_90,  23_90, "Match market minimum on commodity SKU", "match",
   nil, "auto_applied"],
  [4,   6,  34_90,  35_90, "Cheapest by 14,5% with rising demand; elasticity optimum €35,34", "dynamic",
   "Psychological rounding to ,90", "pending_review"]
]

DECISIONS.each do |p_idx, hours_ago, old_p, new_p, trigger, strategy, guardrail, status|
  PricingDecision.create!(
    product: products[p_idx], occurred_at: hours_ago.hours.ago,
    old_price_cents: old_p, new_price_cents: new_p,
    trigger: trigger, strategy: strategy, guardrail: guardrail, status: status
  )
end

puts "Seeded pricing layer: #{ShippingRule.count} shipping rules, #{CompetitorOffer.count} offers, " \
     "#{SaleEvent.count} sale events, #{Campaign.count} campaigns, #{BudgetShift.count} shifts, " \
     "#{AbTest.count} A/B tests, #{ChannelPresence.count} presences, #{PricePoint.count} price points, " \
     "#{PricingDecision.count} pricing decisions."

# --- GrowCentric value added: actual vs modelled baseline (no interventions) --
# The engine went live 70 days ago; before that the baseline equals the actual.
# The attributed share ramps in as repricing, reallocation and new campaigns bite.
live_on = Date.current - 70
ForecastPoint.where.not(actual_cents: nil).order(:day).each do |point|
  days_live = (point.day - live_on).to_i
  share = days_live.positive? ? 0.115 * [days_live / 70.0, 1.0].min**0.7 : 0.0
  wobble = days_live.positive? ? 1.0 + rng.rand(-0.15..0.15) : 1.0
  baseline = (point.actual_cents / (1 + share * wobble)).round
  ValueAddPoint.create!(day: point.day, actual_cents: point.actual_cents, baseline_cents: baseline)
end

puts "Seeded #{ValueAddPoint.count} value-add points " \
     "(total value added: €#{(ValueAddPoint.sum('actual_cents - baseline_cents') / 100.0).round})."

# --- Season relevance per product (same index order as PRODUCTS) ------------
SEASONS = %w[all_season all_season winter all_season winter summer summer summer
             all_season all_season summer winter all_season all_season summer all_season]
products.each_with_index { |product, i| product.update!(season: SEASONS[i]) }

puts "Seeded #{Department.count} departments; product seasons assigned."
