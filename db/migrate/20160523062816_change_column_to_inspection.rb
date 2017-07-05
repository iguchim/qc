class ChangeColumnToInspection < ActiveRecord::Migration
  def change
    change_column :product_logs, :change_date, :datetime
  end
end
