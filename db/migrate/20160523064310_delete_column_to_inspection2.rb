class DeleteColumnToInspection2 < ActiveRecord::Migration
  def change
    remove_column :inspections, :inspect_date
  end
end
