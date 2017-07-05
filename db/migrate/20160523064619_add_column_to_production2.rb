class AddColumnToProduction2 < ActiveRecord::Migration
  def change
    add_column :productions, :inspect_date, :datetime
  end
end
