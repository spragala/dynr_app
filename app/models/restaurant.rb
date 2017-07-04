class Restaurant < ApplicationRecord
  belongs_to :user

  validates :user, presence: true, uniqueness: { scope: :user_id }
  validates :name, presence: true
end
