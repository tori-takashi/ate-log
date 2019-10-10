class CreateRestraunts < ActiveRecord::Migration[5.2]
  def change
    create_table :restraunts do |t|
      t.string :name
      t.float :star
      t.text :link

      t.timestamps
    end
  end
end
