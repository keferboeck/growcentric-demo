class ChannelPresence < ApplicationRecord
  belongs_to :product
  belongs_to :competitor, optional: true # nil = the merchant

  CHANNELS = %w[google_shopping meta tiktok].freeze
end
