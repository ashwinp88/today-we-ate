class AddOccasionToMeals < ActiveRecord::Migration[8.1]
  def change
    add_column :meals, :occasion, :integer
    add_index :meals, [ :user_id, :occasion, :ate_on ]
  end
end
