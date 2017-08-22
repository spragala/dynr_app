class AddRatingToRestaurants < ActiveRecord::Migration[5.1]
  def change
    add_column :restaurants, :rating, :decimal
  end
end
