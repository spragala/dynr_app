class RestaurantsController < ApplicationController
  # include HTTParty
  before_action :require_login

  def index
    if params[:search]
      @restaurants = current_user.restaurants.search(params[:search]).order("created_at DESC")
    else
      @restaurants = current_user.restaurants.order("created_at DESC")
    end
  end

  def new
    @restaurant = current_user.restaurants.build
  end

  def edit
  end

  def update
    # TODO - restaurant = current_user.restaurants.find(params[:id])
    # if @restaurant.update restaurant_params
    # redirect_to restaurants_path
  end

  def create

    # Yelp API - Auth Header
    headers = {
      "Authorization" => "Bearer " + ENV['yelp_api_key']
      }

    # Params to correct format for url
    url_name = restaurant_params['name'].downcase
    url_city = restaurant_params['address'].downcase
    url_rest = 'term=' + url_name.gsub(' ','-') + '&' + 'location=' + url_city.gsub(' ','-')

    # HTTParty - businesses/search endpoint
    endpoint = 'https://api.yelp.com/v3/businesses/search?' << url_rest
    response = HTTParty.get( endpoint, :headers => headers)

    # Response to generate new Restaurant
    # TODO loop through the info and cache the resposes for client to pick which restaurant
    # is the correct one IF there are multiple responses
    if response.success?
      new_restaurant = Hash.new{|h, k| h[k] = ''}

      new_restaurant[:name] << response['businesses'][0]['name']
      new_restaurant[:address] << response['businesses'][0]['location']['display_address'].join(', ')
      new_restaurant[:style] << response['businesses'][0]['categories'][0]['title']
      new_restaurant[:image] << response['businesses'][0]['image_url']
      rating = response['businesses'][0]['rating'].to_i
      new_restaurant[:rating] = rating




      # TODO more regex on form - remove apostrophes

      @restaurant = current_user.restaurants.build(new_restaurant)
      if @restaurant.save
        redirect_to restaurants_path
       else
         flash[:error] = 'Something went wrong, try your search again.'
         redirect_to new_restaurant_path
      end
    else
      flash[:error] = 'No restaurant found with that name, please try again.'
      redirect_to new_restaurant_path
    end

  end

  def destroy
    restaurant = current_user.restaurants.find(params[:id])
    restaurant.destroy
    redirect_to restaurants_path(restaurant), notice: "Deleted Restaurant: #{restaurant.name}"
  end

  private

  def restaurant_params
    params.require(:restaurant).permit(:name, :address, :notes)
  end

end
