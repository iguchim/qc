class AddColumnToProduction < ActiveRecord::Migration
  def change
    add_column :inspections, :inspect_date, :datetime
  end
end
