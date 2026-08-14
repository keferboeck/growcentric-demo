# Demo data feed for the Velora test store landing page.
#
# Time is cut into fixed 5 second slots and each slot seeds its own PRNG, so
# the event stream is a pure function of the clock: every visitor computes the
# identical events for the same moment (consistent across browsers), each slot
# yields its event exactly once (nothing ever repeats), and no state is stored.
module VeloraFeed
  TICK = 5                                          # seconds per slot
  WINDOW = 360                                      # never look further back than 30 min
  BACKFILL_LINES = 22

  # Orders live on a coarser 60 second grid so the order counter climbs at a
  # believable pace (one number per minute) while staying strictly unique and
  # increasing: each grid slot owns exactly one number, taken or skipped.
  ORDER_EVERY = 12
  ORDER_BASE = 50_000 - Time.utc(2026, 1, 1).to_i / TICK / ORDER_EVERY

  # Non-order event kinds and their relative weights.
  KINDS = [
    [:visitor, 25], [:crawler, 20], [:stock, 10],
    [:pricing, 10], [:content, 8], [:pixel, 8], [:model, 7]
  ].freeze

  CITIES = [
    "Munich, DE", "Vienna, AT", "Zurich, CH", "Berlin, DE", "Hamburg, DE",
    "Graz, AT", "Innsbruck, AT", "Stuttgart, DE", "Cologne, DE", "Salzburg, AT",
    "Basel, CH", "Leipzig, DE", "Linz, AT", "Frankfurt, DE", "Dresden, DE"
  ].freeze
  PAYMENTS = ["Visa", "Mastercard", "PayPal", "Klarna", "Apple Pay", "SEPA"].freeze
  PAGES = ["/", "/collections/road", "/collections/gravel", "/collections/mtb",
           "/collections/accessories", "/sale", "/service/bike-fitting"].freeze
  PIXEL_EVENTS = [["PageView", 55], ["ViewContent", 25], ["AddToCart", 14], ["Purchase", 6]].freeze

  module_function

  def current_slot = Time.now.to_i / TICK

  def backfill
    events_between(current_slot - WINDOW, current_slot).last(BACKFILL_LINES)
  end

  def since(after_slot)
    from = [after_slot + 1, current_slot - WINDOW].max
    events_between(from, current_slot)
  end

  def events_between(from, to)
    (from..to).filter_map { |slot| event_for(slot) }
  end

  def event_for(slot)
    rng = Random.new((slot * 2_654_435_761) % 4_294_967_291)
    if (slot % ORDER_EVERY).zero? && rng.rand < 0.6
      return build(slot, :order, order_line(slot, rng))
    end
    return nil unless rng.rand < 0.5

    kind = weighted(KINDS, rng)
    build(slot, kind, public_send("#{kind}_line", slot, rng))
  end

  def build(slot, kind, line)
    { slot: slot, time: Time.at(slot * TICK).utc.strftime("%H:%M:%S"), kind: kind.to_s, line: line }
  end

  def weighted(pairs, rng)
    roll = rng.rand(pairs.sum { |_, weight| weight })
    pairs.each { |value, weight| return value if (roll -= weight) < 0 }
  end

  def visitor_line(_slot, rng)
    "session #{hex(rng, 6)} · visitor from #{pick(CITIES, rng)} · viewing #{pick(PAGES, rng)}"
  end

  def crawler_line(_slot, rng)
    name, cents = pick(products, rng)
    delta = format("%+.1f%%", rng.rand * 3.0 - 1.5)
    "#{pick(competitors, rng)} · #{name} listed at #{euro(jitter(cents, rng))} (#{delta} vs us)"
  end

  def order_line(slot, rng)
    name, cents = pick(products, rng)
    qty = rng.rand < 0.8 ? 1 : rng.rand(2..3)
    "order #VL-#{ORDER_BASE + slot / ORDER_EVERY} · #{qty}x #{name} · #{euro(cents * qty)} · #{pick(PAYMENTS, rng)}"
  end

  def stock_line(_slot, rng)
    name, = pick(products, rng)
    level = rng.rand(3..48)
    "inventory sync · #{name} · stock #{level} -> #{level + rng.rand(-2..4)}"
  end

  def pricing_line(_slot, rng)
    name, cents = pick(products, rng)
    "#{name} · #{euro(cents)} -> #{euro(jitter(cents, rng))} · margin guard ok"
  end

  def content_line(_slot, rng)
    name, = pick(products, rng)
    "meta description rewritten for #{name} · +#{rng.rand(3..9)} keywords"
  end

  def pixel_line(_slot, rng)
    event = weighted(PIXEL_EVENTS, rng)
    value = event == "Purchase" ? " · value #{euro(pick(products, rng).last)}" : ""
    "#{event} matched server side#{value} · event_id #{hex(rng, 8)}"
  end

  def model_line(_slot, rng)
    "demand model refreshed · MAPE #{format('%.1f', 5.5 + rng.rand * 3.5)}% · horizon 30d"
  end

  def pick(list, rng) = list[rng.rand(list.size)]

  def hex(rng, length) = length.times.map { rng.rand(16).to_s(16) }.join

  def euro(cents) = format("€%.2f", cents / 100.0)

  def jitter(cents, rng) = (cents * (0.97 + rng.rand * 0.06)).round

  # Catalog data comes from the demo database so the feed talks about the same
  # products and competitors as the app itself. Ordered by id so every process
  # sees the same list, which keeps the seeded picks identical across servers.
  def products
    @products ||= Product.order(:id).pluck(:name, :price_cents).presence ||
                  [["Velora Allroad Ti", 289_900], ["Velora Gravel 2", 179_900]]
  end

  def competitors
    @competitors ||= Competitor.order(:id).pluck(:name).presence ||
                     ["bike24.de", "rosebikes.de", "fahrrad.de"]
  end
end
