class AddOccasionToRecommendationEvents < ActiveRecord::Migration[8.1]
  def change
    add_column :recommendation_events, :occasion, :integer
    add_index :recommendation_events, :occasion
  end
end
