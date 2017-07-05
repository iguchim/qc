class CreateProductions < ActiveRecord::Migration
  def change
    create_table :productions do |t|
      t.string :lot
      t.integer :pcs
      t.references :product, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
