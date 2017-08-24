class Restaurant < ApplicationRecord
  belongs_to :user

  validates :name, presence: true, uniqueness: { scope: :user_id }
  validates :user, presence: true

  def self.search(search)
    where("name ILIKE ?", "%#{search}%")
  end

  def self.get_rest(input)
      # Yelp API - Auth Header
    headers = {
      "Authorization" => "Bearer " + ENV['yelp_api_key']
      }

    # Params to correct format for url
    url_name = input['name'].downcase
    url_city = input['address'].downcase
    url_rest = 'term=' + url_name.gsub(' ','-') + '&' + 'location=' + url_city.gsub(' ','-')

    # HTTParty - businesses/search endpoint
    endpoint = 'https://api.yelp.com/v3/businesses/search?' << url_rest
    response = HTTParty.get( endpoint, :headers => headers)

    if response.success?
      return response['businesses']
    else
      flash[:error] = 'No restaurant found with that name, please try again.'
      redirect_to new_restaurant_path
    end
  end

end
