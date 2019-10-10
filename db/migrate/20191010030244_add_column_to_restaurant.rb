class AddColumnToRestaurant < ActiveRecord::Migration[5.2]
    def change
        add_column :restaurants, :location, :string
    end
end
