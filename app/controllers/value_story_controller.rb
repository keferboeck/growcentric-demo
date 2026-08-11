class ValueStoryController < ApplicationController
  def index
    @daily = ValueAddPoint.chronological.to_a
    @value_added_cents = @daily.sum(&:value_added_cents)
    today = Date.current
    # Minor auto-actions (repricings, budget nudges) shown as small dots between the numbered events
    @minor_days = [-64, -61, -57, -50, -44, -40, -33, -26, -23, -17, -14, -11, -6, -3].map { |offset| today + offset }

    @events = [
      { n: 1, day: today - 71, type: :milestone, effect: nil, status: :milestone,
        title: "Engine goes live", link: nil,
        body: "Crawler, repricing engine and budget allocator switch on. The baseline model freezes here: everything above it is attributable value." },
      { n: 2, day: today - 66, type: :repricing, effect: +310_00, status: :compounding,
        title: "First repricing wave: 6 SKUs aligned", link: :dynamic_pricing,
        body: "Sealant, Bottom Bracket and four more SKUs moved to market-aware prices inside guardrails. Small steps, no competitor reaction (heat below 25 on all six)." },
      { n: 3, day: today - 59, type: :ab_test, effect: +180_00, status: :compounding,
        title: "A/B win: \"MIPS-certified protection\"", link: :campaigns,
        body: "The safety-led headline beat the price-led one at 97,2% significance (+44% CTR). Auto-rolled out to the whole helmet campaign." },
      { n: 4, day: today - 52, type: :setback, effect: -240_00, status: :setback,
        title: "Bid strategy test backfires", link: :campaigns,
        body: "tROAS 380% on Lights core chased volume into a price war: CPCs +31%, POAS fell from 0,76 to 0,55. The wedge visibly narrows this week: the one move that cost value." },
      { n: 5, day: today - 46, type: :correction, effect: +240_00, status: :corrected,
        title: "Guardrail rollback + budget cut", link: :campaigns,
        body: "The POAS floor guardrail caught the drift after 6 days and rolled the bid strategy back automatically. The freed €700/month became the seed of the Bikepacking shift. Net effect of events 4+5: recovered, lesson logged." },
      { n: 6, day: today - 38, type: :budget, effect: +430_00, status: :compounding,
        title: "Budget shift: €1.800 Lights → Bikepacking", link: :campaigns,
        body: "The allocator's biggest single win. Lights core was earning 0,76× POAS; Bikepacking runs 3,22× and had 61% impression share lost to budget. The wedge steepens from here." },
      { n: 7, day: today - 29, type: :repricing, effect: +220_00, status: :compounding,
        title: "Beacon 1200: first price step (€114,90)", link: :dynamic_pricing,
        body: "Answering Lichtblick inside guardrails. They followed within 6 hours (heat 94), but conversion recovered and the ad pause was avoided." },
      { n: 8, day: today - 20, type: :campaign, effect: +200_00, status: :compounding,
        title: "Orbit TikTok test launches", link: :campaigns,
        body: "The hidden gem gets its first paid push: 55% margin, zero competitor ad presence, 1,98× POAS and climbing. Still capped at €600 while the test runs." },
      { n: 9, day: today - 9, type: :repricing, effect: +150_00, status: :compounding,
        title: "Beacon €109,90 + KVI premium hold", link: :dynamic_pricing,
        body: "Second Beacon step, while Crest MIPS and Merino hold premium positions (visibility 82 and 76 carry them). Pricing down where it defends, up where the brand allows." }
    ]
  end
end
