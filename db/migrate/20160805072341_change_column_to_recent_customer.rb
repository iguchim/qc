class ChangeColumnToRecentCustomer < ActiveRecord::Migration
  def change
    rename_column :recent_customers, :customer_id_id, :customer_id
  end
end
