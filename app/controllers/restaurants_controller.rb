class RestaurantsController < ApplicationController
  # include HTTParty
  before_action :require_login

  def index
    @restaurants = current_user.restaurants
    if params[:search]
      @restaurants = current_user.restaurants.search(params[:search]).order("created_at DESC")
    else
      @restaurants = current_user.restaurants.order("created_at ASC")
    end
  end

  def new
    @restaurant = current_user.restaurants.build
  end

  def create

    headers = {
      "Authorization" => "Bearer " + ENV['yelp_api_key']
      }

    url_name = restaurant_params['name'].downcase
    url_city = restaurant_params['address'].downcase
    url_rest = url_name.gsub(' ','-') + '-' + url_city.gsub(' ','-')

    endpoint = 'https://api.yelp.com/v3/businesses/' << url_rest
    response = HTTParty.get( endpoint, :headers => headers)

    if response.success?
      new_restaurant = Hash.new{|h, k| h[k] = ''}

      new_restaurant[:name] << response['name']
      new_restaurant[:address] << response['location']['display_address'].join(', ')
      new_restaurant[:style] << response['categories'][0]['title']
      new_restaurant[:image] << response['photos'][0]

      # TODO merge integer into the Hash
      # rating = response['rating'].to_number
      # new_restaurant << rating
      # TODO more regex on form - remove apostrophes

      # TODO notes merge into new_restaurant array

      @restaurant = current_user.restaurants.build(new_restaurant)
      if @restaurant.save
        redirect_to restaurants_path(@restaurant)
       else
         flash[:error] = 'Something went wrong, try your search again.'
         redirect_to new_restaurant_path
      end
    else
      flash[:error] = 'No restaurant found with that name, please try again.'
      redirect_to new_restaurant_path
      # render: new ^
    end

  end

  def destroy
    restaurant = current_user.restaurants.find(params[:id])
    restaurant.destroy
    redirect_to restaurants_path(restaurant), notice: "Deleted Restaurant: #{restaurant.name}"
  end

  # def edit {
  #   @notes = current_user.restaurants.find(params[:id])
  #   if @notes.update restaurant_params
  #     redirect to restaurants_path
  #   else
  #     flash[:error]
  #     render:
  # }

  private

  def restaurant_params
    params.require(:restaurant).permit(:name, :address, :notes)
  end

end
