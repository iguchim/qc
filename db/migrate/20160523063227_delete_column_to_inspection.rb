class DeleteColumnToInspection < ActiveRecord::Migration
  def change
    remove_column :product_logs, :datetime
  end
end
