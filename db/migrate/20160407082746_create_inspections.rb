class CreateInspections < ActiveRecord::Migration
  def change
    create_table :inspections do |t|
      t.integer :num
      t.string :synopsis
      t.string :standard
      t.float :min
      t.float :max
      t.string :tool
      t.string :unit
      t.references :product, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
