class CreateSummaries < ActiveRecord::Migration[5.2]
  def change
    create_table :summaries do |t|
      t.text :summary_data
      t.string :location

      t.timestamps
    end
  end
end
