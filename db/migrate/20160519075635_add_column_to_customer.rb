class AddColumnToCustomer < ActiveRecord::Migration
  def change
    add_column :customers, :code, :integer
  end
end
