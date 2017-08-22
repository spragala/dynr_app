class CreateRestaurants < ActiveRecord::Migration[5.1]
  def change
    create_table :restaurants do |t|
      t.string :name, null: false
      t.text :notes
      t.string :address
      t.string :style
      t.string :image
      t.decimal :rating
      t.string :phone
      t.string :url
      t.decimal :latitude
      t.decimal :longitude
      t.belongs_to :user, null: false, foreign_key: true

      t.timestamps null: false
    end

    add_index :restaurants, [:user_id, :name]
  end
end
