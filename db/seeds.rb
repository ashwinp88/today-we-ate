# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
if Rails.env.development?
  user = User.find_or_create_by!(provider: "developer", uid: "demo") do |u|
    u.name = "Demo Diner"
    u.email = "demo@example.com"
  end

  next_try = [7, 14, 30, nil]
  %w[Tacos Pizza Ramen Salad Curry Sandwich].each_with_index do |meal_name, index|
    user.meals.find_or_create_by!(name: meal_name, ate_on: (index + 1).days.ago.to_date) do |meal|
      meal.source = Meal.sources.keys.sample
      meal.rating = (3..5).to_a.sample
      meal.retry_in_days = next_try.sample
      meal.notes = "Seed meal"
    end
  end
end
