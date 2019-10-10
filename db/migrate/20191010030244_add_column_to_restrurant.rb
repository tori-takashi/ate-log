class AddColumnToRestrurant < ActiveRecord::Migration[5.2]
    def change
        add_column :restraunts, :location, :string
    end
end
