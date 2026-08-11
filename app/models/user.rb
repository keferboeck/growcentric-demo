class User < ApplicationRecord
  # Invite-only beta: no :registerable, accounts are created via seeds/console.
  devise :database_authenticatable, :recoverable, :rememberable, :validatable
end
