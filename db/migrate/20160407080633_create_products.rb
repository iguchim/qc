class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string :num
      t.string :name
      t.string :material
      t.string :surface
      t.string :heat
      t.references :customer, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
