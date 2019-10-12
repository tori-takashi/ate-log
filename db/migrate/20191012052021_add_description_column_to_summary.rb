class AddDescriptionColumnToSummary < ActiveRecord::Migration[5.2]
  def change
    add_column :summaries, :data_description, :text
  end
end
