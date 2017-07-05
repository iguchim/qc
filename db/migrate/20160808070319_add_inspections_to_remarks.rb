class AddInspectionsToRemarks < ActiveRecord::Migration
  def change
    add_column :inspections, :remark, :string
  end
end
