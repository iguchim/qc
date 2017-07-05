class CreateInspectData < ActiveRecord::Migration
  def change
    create_table :inspect_data do |t|
      t.float :num_data
      t.string :str_data
      t.references :production, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
