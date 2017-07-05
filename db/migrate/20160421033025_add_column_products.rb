class AddColumnProducts < ActiveRecord::Migration
  def change
    add_column :products, :code, :string
  end
end
