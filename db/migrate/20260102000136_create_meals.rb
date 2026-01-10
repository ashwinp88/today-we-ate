class CreateMeals < ActiveRecord::Migration[8.1]
  def change
    create_table :meals do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.integer :source, null: false, default: 0
      t.integer :rating, null: false
      t.date :ate_on, null: false
      t.integer :retry_in_days
      t.text :notes

      t.timestamps
    end

    add_index :meals, [:user_id, :ate_on]
    add_index :meals, [:user_id, :name]
  end
end
