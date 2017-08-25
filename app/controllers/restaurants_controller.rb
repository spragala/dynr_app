class RestaurantsController < ApplicationController
  # include HTTParty
  before_action :require_login
  # before_action :pick_rest, only: [:create]

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

  def pick_rest
    # if multiple display multiples
    # display with add button
    # when button clicked create new
    @restaurant = current_user.restaurants.get_rest(params[:restaurant])
    # if one response create new
    # @restaurant = current_user.restarurants.create?
  end

  def create

  # Response to generate new Restaurant

    new_restaurant = Hash.new{|h, k| h[k] = ''}
    
    new_restaurant[:name] << params['name']
    new_restaurant[:address] << params['location']['display_address'].join(', ')
    new_restaurant[:style] << params['categories'][0]['title']
    new_restaurant[:image] << params['image_url']
    rating = params['rating'].to_i
    new_restaurant[:rating] = rating

    @restaurant = current_user.restaurants.build(new_restaurant)

    if @restaurant.save
      redirect_to restaurants_path
     else
       flash[:error] = 'Something went wrong, try your search again.'
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
