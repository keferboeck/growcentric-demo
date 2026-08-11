class ForecastController < ApplicationController
  def index
    @points = ForecastPoint.chronological
    @forecast_30d_cents = ForecastPoint.where(day: Date.current + 1..Date.current + 30).sum(:forecast_cents)
    @actual_30d_cents = ForecastPoint.where(day: 29.days.ago.to_date..Date.current).sum(:actual_cents)
    @early_warning = Alert.where(kind: "early_warning").recent.first
    @weekly = @points.group_by { |p| p.day.beginning_of_week }
                     .map do |week, pts|
                       {
                         week: week,
                         actual: pts.filter_map(&:actual_cents).then { |a| a.empty? ? nil : a.sum },
                         forecast: pts.sum(&:forecast_cents),
                         lower: pts.sum(&:lower_cents),
                         upper: pts.sum(&:upper_cents)
                       }
                     end
  end
end
