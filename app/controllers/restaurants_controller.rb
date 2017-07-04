class RestaurantsController < ApplicationController
  # include HTTParty
  before_action :require_login

  def index
    @restaurants = current_user.restaurants
  end

  def new
    @restaurant = current_user.restaurants.build
  end

  def create
    headers = {
      "Authorization" => "Bearer UKWxH_2pKgsmhYvw3sfPK08BPbQFVB2ZkM4umAhZ47NAS7Z-YNdBY-ggeF8mv4JdrWcwNuk7aAErQEwLZkiHehETJTHRMoawVexgx4DU-SSZWboxyaUxBRciTM0wWXYx"
      }

    url_name = restaurant_params['name'].downcase
    url_city = restaurant_params['address'].downcase
    url_rest = url_name.gsub(' ','-') + '-' + url_city.gsub(' ','-')

    endpoint = 'https://api.yelp.com/v3/businesses/' << url_rest
    response = HTTParty.get( endpoint, :headers => headers)

    new_restaurant = Hash.new{|h, k| h[k] = ''}

    new_restaurant[:name] << response['name']
    new_restaurant[:address] << response['location']['display_address'].join(', ')
    new_restaurant[:style] << response['categories'][0]['title']
    new_restaurant[:image] << response['photos'][1]

    # TODO new_restaurant.merge(:rating => response['rating'])

    # TODO merge integer into the Hash

    # TODO .map the address to get full address`

    # TODO add error handling for failed searches. Try below.
    # if response.success?
    #   response
    # else
    #   raise response.response
    # end

    @restaurant = current_user.restaurants.build(new_restaurant)
    if @restaurant.save
      redirect_to restaurants_path(@restaurant)
    # else
    #   flash[:error] = current_user.restaurants.full_messages.join(' ')
    #   render :new
    end

  end

  def destroy
    restaurant = current_user.restaurants.find(params[:id])
    restaurant.destroy
    redirect_to restaurants_path(restaurant), notice: "Deleted Restaurant: #{restaurant.name}"
  end

  private

  def restaurant_params
    params.require(:restaurant).permit(:name, :address)
  end

end
