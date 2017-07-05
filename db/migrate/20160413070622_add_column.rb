class AddColumn < ActiveRecord::Migration
  def change
    add_column :inspect_data, :inspection_id, :integer
    add_index :inspect_data, :inspection_id
  end
end
