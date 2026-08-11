class Campaign < ApplicationRecord
  has_many :ab_tests, dependent: :destroy

  CHANNEL_LABELS = { "google_shopping" => "Google Shopping", "meta" => "Meta", "tiktok" => "TikTok" }.freeze

  def channel_label = CHANNEL_LABELS.fetch(channel, channel)
  def roas = spend_30d_cents.zero? ? 0 : revenue_30d_cents.to_f / spend_30d_cents
  # POAS = ROAS × gross margin, the profitability lens from the playbook
  def poas = roas * margin_pct / 100.0
end
