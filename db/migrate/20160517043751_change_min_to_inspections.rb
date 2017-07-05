class ChangeMinToInspections < ActiveRecord::Migration
  def change
    change_column :inspections, :min, :string
    change_column :inspections, :max, :string
  end
end
