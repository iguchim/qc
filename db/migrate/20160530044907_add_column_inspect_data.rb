class AddColumnInspectData < ActiveRecord::Migration
  def change
    add_column :inspect_data, :num, :integer
  end
end
