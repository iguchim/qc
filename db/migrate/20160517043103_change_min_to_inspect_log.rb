class ChangeMinToInspectLog < ActiveRecord::Migration
  def change
    change_column :inspect_logs, :min, :string
    change_column :inspect_logs, :max, :string
  end
end
