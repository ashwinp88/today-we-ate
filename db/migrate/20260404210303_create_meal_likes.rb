class CreateMealLikes < ActiveRecord::Migration[8.1]
  def change
    create_table :meal_likes do |t|
      t.references :user, null: false, foreign_key: true
      t.references :meal, null: false, foreign_key: true

      t.timestamps
    end

    add_index :meal_likes, [ :user_id, :meal_id ], unique: true
  end
end
