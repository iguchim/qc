class CreateProductLogs < ActiveRecord::Migration
  def change
    create_table :product_logs do |t|
      t.string :code
      t.string :num
      t.string :name
      t.string :material
      t.string :heat 
      t.string :surface
      t.string :change_date
      t.string :datetime
      t.string :remark
      t.references :product, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
