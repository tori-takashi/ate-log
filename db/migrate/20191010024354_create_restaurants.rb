class CreateRestaurants < ActiveRecord::Migration[5.2]
  def change
    create_table :restaurants do |t|
      t.string :name
      t.float :star
      t.text :link

      t.timestamps
    end
  end
end
