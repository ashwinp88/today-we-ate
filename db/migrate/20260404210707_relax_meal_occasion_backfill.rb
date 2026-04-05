class RelaxMealOccasionBackfill < ActiveRecord::Migration[8.1]
  def up
    change_column_default :meals, :occasion, from: 3, to: nil
    change_column_null :meals, :occasion, true
    execute <<~SQL
      UPDATE meals
      SET occasion = NULL
      WHERE occasion = 3
    SQL
  end

  def down
    execute <<~SQL
      UPDATE meals
      SET occasion = 3
      WHERE occasion IS NULL
    SQL
    change_column_null :meals, :occasion, false
    change_column_default :meals, :occasion, from: nil, to: 3
  end
end
