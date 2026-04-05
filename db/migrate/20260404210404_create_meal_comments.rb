class CreateMealComments < ActiveRecord::Migration[8.1]
  def change
    create_table :meal_comments do |t|
      t.references :user, null: false, foreign_key: true
      t.references :meal, null: false, foreign_key: true
      t.text :body, null: false

      t.timestamps
    end

    add_index :meal_comments, [ :meal_id, :created_at ]
  end
end
