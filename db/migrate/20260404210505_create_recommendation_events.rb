class CreateRecommendationEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :recommendation_events do |t|
      t.references :user, null: false, foreign_key: true
      t.string :event_name, null: false
      t.string :source_type, null: false
      t.string :meal_name, null: false
      t.jsonb :metadata, null: false, default: {}

      t.timestamps
    end

    add_index :recommendation_events, :event_name
    add_index :recommendation_events, :source_type
  end
end
