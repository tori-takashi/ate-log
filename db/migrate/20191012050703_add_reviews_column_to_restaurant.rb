class AddReviewsColumnToRestaurant < ActiveRecord::Migration[5.2]
  def change
    add_column :restaurants, :reviews, :integer
  end
end
