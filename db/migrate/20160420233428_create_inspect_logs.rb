class CreateInspectLogs < ActiveRecord::Migration
  def change
    create_table :inspect_logs do |t|
      t.string :num
      t.string :kind
      t.string :synopsis
      t.string :standard
      t.float :min
      t.float :max
      t.string :tool
      t.string :unit
      t.datetime :change_date
      t.string :remark
      t.references :product, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
