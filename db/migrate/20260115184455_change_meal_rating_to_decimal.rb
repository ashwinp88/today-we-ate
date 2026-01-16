class ChangeMealRatingToDecimal < ActiveRecord::Migration[8.0]
  def change
    change_column :meals, :rating, :decimal, precision: 2, scale: 1, null: false
  end
end
