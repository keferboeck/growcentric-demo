module ApplicationHelper
  def euro(cents, precision: 0)
    number_to_currency(cents / 100.0, unit: "€", format: "%u%n", delimiter: ".", separator: ",", precision: precision)
  end

  def euro_compact(cents)
    value = cents / 100.0
    if value >= 1_000_000
      "€#{number_with_precision(value / 1_000_000, precision: 1, separator: ',').sub(',0', '')}M"
    elsif value >= 10_000
      "€#{number_with_precision(value / 1_000, precision: 1, separator: ',').sub(',0', '')}K"
    else
      euro(cents)
    end
  end

  def signed_pct(value)
    "#{value.positive? ? '+' : ''}#{number_with_precision(value, precision: 1, separator: ',')}%"
  end

  def status_badge(status)
    styles = {
      "hidden_gem" => "bg-accent-50 text-accent-700 ring-accent-600/20",
      "bestseller" => "bg-emerald-50 text-emerald-700 ring-emerald-600/20",
      "losing"     => "bg-rose-50 text-rose-700 ring-rose-600/20",
      "steady"     => "bg-gray-50 text-gray-600 ring-gray-500/10"
    }
    labels = { "hidden_gem" => "Hidden gem", "bestseller" => "Bestseller", "losing" => "Losing ground", "steady" => "Steady" }
    tag.span(dt(labels.fetch(status, status)), class: "inline-flex items-center rounded-md px-2 py-1 text-xs font-medium ring-1 ring-inset #{styles.fetch(status, styles['steady'])}")
  end

  def position_badge(position, delta_pct)
    case position
    when "better"
      tag.span(dt("%{pct} better", pct: signed_pct(delta_pct)), class: "inline-flex items-center gap-1 rounded-md bg-emerald-50 px-2 py-1 text-xs font-medium text-emerald-700 ring-1 ring-inset ring-emerald-600/20")
    when "worse"
      tag.span(dt("%{pct} worse", pct: signed_pct(delta_pct)), class: "inline-flex items-center gap-1 rounded-md bg-rose-50 px-2 py-1 text-xs font-medium text-rose-700 ring-1 ring-inset ring-rose-600/20")
    else
      tag.span(dt("at par"), class: "inline-flex items-center rounded-md bg-gray-50 px-2 py-1 text-xs font-medium text-gray-600 ring-1 ring-inset ring-gray-500/10")
    end
  end

  def severity_badge(severity)
    styles = {
      "critical" => "bg-rose-50 text-rose-700 ring-rose-600/20",
      "warning"  => "bg-amber-50 text-amber-700 ring-amber-600/20",
      "info"     => "bg-sky-50 text-sky-700 ring-sky-600/20"
    }
    tag.span(dt(severity.capitalize), class: "inline-flex items-center rounded-md px-2 py-1 text-xs font-medium ring-1 ring-inset #{styles.fetch(severity)}")
  end

  def trend_text(value)
    if value.positive?
      tag.span("▲ #{signed_pct(value)}", class: "font-medium text-emerald-600")
    elsif value.negative?
      tag.span("▼ #{signed_pct(value)}", class: "font-medium text-rose-600")
    else
      tag.span("-", class: "text-gray-400")
    end
  end
end
