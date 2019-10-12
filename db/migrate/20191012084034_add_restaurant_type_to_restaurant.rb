class AddRestaurantTypeToRestaurant < ActiveRecord::Migration[5.2]
  def change
    add_column :restaurants, :restaurant_user_type, :string
  end
end
