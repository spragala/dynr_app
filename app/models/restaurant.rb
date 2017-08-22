class Restaurant < ApplicationRecord
  belongs_to :user

  validates :name, presence: true, uniqueness: { scope: :user_id }
  validates :user, presence: true

  def self.search(search)
    where("name ILIKE ?", "%#{search}%")
  end

  def self.get_rest
    # TODO - move Yelp API call into here
  end

end
