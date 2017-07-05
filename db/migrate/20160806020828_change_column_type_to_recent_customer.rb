class ChangeColumnTypeToRecentCustomer < ActiveRecord::Migration
  def change
    change_column :recent_customers, :access_date, :datetime
  end
end
