# Display currency for localised demo screenshots. All demo data stays
# euro-denominated; when a non-EUR currency is selected, the rendered HTML
# is rewritten on the way out: every German-formatted euro amount
# ("€99,90", "+€1.490", "€30,9K", "€0,038") is converted at a fixed rate
# and reformatted in anglo style ("£85.37", "+$1,720", "$35.7K").
# One conversion point, no view churn, hardcoded copy included.
module DemoCurrency
  # EUR-based mid-market rates of 11 Aug 2026 (exchangerate-api.com),
  # matching the landing site's pricing table.
  CURRENCIES = {
    "EUR" => { symbol: "€", rate: 1.0 },
    "GBP" => { symbol: "£", rate: 0.8545 },
    "USD" => { symbol: "$", rate: 1.1541 },
    "CAD" => { symbol: "$", rate: 1.6072 },
    "AUD" => { symbol: "$", rate: 1.6344 },
    "NZD" => { symbol: "$", rate: 1.9629 }
  }.freeze

  # "€50-150": both ends share one € sign, so both must convert.
  RANGE = /€(\d+)-(\d+)/

  # Sign (incl. unicode minus) + € + German-formatted number + optional K/M.
  AMOUNT = /([+\-−±]?)€\s?(\d{1,3}(?:\.\d{3})+|\d+)(?:,(\d+))?([KM])?/

  # German decimal commas in percentages ("+2,5%") read wrong next to
  # anglo-formatted money, so they switch to a decimal point too.
  PERCENT = /(\d+),(\d+)\s?%/

  def self.rewrite(html, code)
    currency = CURRENCIES.fetch(code, nil)
    return html if currency.nil? || code == "EUR"

    html
      .gsub(RANGE) do
        low = ($1.to_f * currency[:rate]).round
        high = ($2.to_f * currency[:rate]).round
        "#{currency[:symbol]}#{low}-#{high}"
      end
      .gsub(AMOUNT) do
        sign, whole, decimals, suffix = $1, $2, $3, $4
        value = "#{whole.delete('.')}.#{decimals || 0}".to_f * currency[:rate]
        "#{sign}#{currency[:symbol]}#{format_number(value, decimals, suffix)}#{suffix}"
      end
      .gsub(PERCENT, '\1.\2%')
  end

  def self.format_number(value, decimals, suffix)
    precision = if suffix then 1
                elsif decimals then decimals.length
                else 0
                end
    rounded = value.round(precision)
    whole, frac = format("%.#{precision}f", rounded).split(".")
    frac = nil if suffix && frac == "0"
    grouped = whole.gsub(/(\d)(?=(\d{3})+$)/, '\1,')
    frac ? "#{grouped}.#{frac}" : grouped
  end
end
