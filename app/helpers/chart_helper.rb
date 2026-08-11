module ChartHelper
  # Maps forecast points onto SVG coordinates and returns everything a view
  # needs to draw the revenue chart: paths, band polygon, ticks, today marker.
  def forecast_chart_data(points, width:, height:, pad_left: 48, pad_right: 76, pad_y: 18)
    days = points.map(&:day)
    values = points.flat_map { |p| [p.actual_cents, p.upper_cents, p.lower_cents].compact }
    max = values.max * 1.05
    min = [values.min * 0.95, 0].max

    x = ->(day) { pad_left + (day - days.first).to_f / (days.last - days.first) * (width - pad_left - pad_right) }
    y = ->(cents) { pad_y + (1 - (cents - min) / (max - min)) * (height - 2 * pad_y) }

    actual = points.select(&:actual_cents)
    future = points.select { |p| p.day >= Date.current }

    {
      x: x, y: y, min: min, max: max,
      actual_path: svg_path(actual.map { |p| [x.(p.day), y.(p.actual_cents)] }),
      forecast_path: svg_path(future.map { |p| [x.(p.day), y.(p.forecast_cents)] }),
      band_points: (future.map { |p| "#{x.(p.day).round(1)},#{y.(p.upper_cents).round(1)}" } +
                    future.reverse.map { |p| "#{x.(p.day).round(1)},#{y.(p.lower_cents).round(1)}" }).join(" "),
      today_x: x.(Date.current),
      last_actual: actual.last,
      last_forecast: future.last,
      y_ticks: y_axis_ticks(min, max),
      month_ticks: days.select { |d| d.day == 1 }.map { |d| [x.(d), I18n.l(d, format: "%b")] }
    }
  end

  def sparkline_path(values, width:, height:, pad: 2)
    return "" if values.size < 2
    min, max = values.minmax
    range = [max - min, 1].max
    pts = values.each_with_index.map do |v, i|
      [pad + i.to_f / (values.size - 1) * (width - 2 * pad),
       pad + (1 - (v - min).to_f / range) * (height - 2 * pad)]
    end
    svg_path(pts)
  end

  # List price (step line), average sold price (line) and market-min index
  # (separate mini chart: different unit, so never on the same axis).
  def price_chart_data(points, width:, height:, index_height:, pad_left: 52, pad_right: 24, pad_y: 14)
    days = points.map(&:day)
    prices = points.flat_map { |p| [p.list_price_cents, p.avg_sold_price_cents].compact }
    max = prices.max * 1.04
    min = prices.min * 0.96

    x = ->(day) { pad_left + (day - days.first).to_f / (days.last - days.first) * (width - pad_left - pad_right) }
    y = ->(cents) { pad_y + (1 - (cents - min) / (max - min)) * (height - 2 * pad_y) }

    step = points.each_with_index.map do |p, i|
      px = x.(p.day).round(1)
      py = y.(p.list_price_cents).round(1)
      i.zero? ? "M#{px} #{py}" : "L#{px} #{prev_y = y.(points[i - 1].list_price_cents).round(1)} L#{px} #{py}"
    end.join(" ")

    sold = points.select(&:avg_sold_price_cents)

    idx_values = points.map(&:market_min_index)
    idx_max = [idx_values.max * 1.02, 1.05].max
    idx_min = [idx_values.min * 0.98, 0.95].min
    iy = ->(v) { 8 + (1 - (v - idx_min) / (idx_max - idx_min)) * (index_height - 16) }

    {
      x: x, y: y,
      step_path: step,
      sold_path: svg_path(sold.map { |p| [x.(p.day), y.(p.avg_sold_price_cents)] }),
      y_ticks: y_axis_ticks(min, max),
      month_ticks: days.select { |d| d.day == 1 }.map { |d| [x.(d), I18n.l(d, format: "%b")] },
      index_path: svg_path(points.map { |p| [x.(p.day), iy.(p.market_min_index)] }),
      index_parity_y: iy.(1.0),
      last_point: points.last,
      last_sold: sold.last
    }
  end

  private

  def svg_path(pts)
    pts.each_with_index.map { |(px, py), i| "#{i.zero? ? 'M' : 'L'}#{px.round(1)} #{py.round(1)}" }.join(" ")
  end

  def y_axis_ticks(min, max)
    steps = [1_00, 2_00, 5_00, 10_00, 25_00, 50_00, 100_00, 250_00, 500_00,
             1_000_00, 2_000_00, 5_000_00, 10_000_00, 20_000_00]
    step = steps.find { |s| (max - min) / s <= 6 } || steps.last
    first = (min / step.to_f).ceil * step
    (first..max.to_i).step(step).to_a
  end
end
