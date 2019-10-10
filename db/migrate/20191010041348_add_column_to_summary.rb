class AddColumnToSummary < ActiveRecord::Migration[5.2]
  def change
    add_column :summaries, :summary_type, :string
  end
end
