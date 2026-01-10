class MealAnalytics
  WINDOWS = {
    week: 1.week,
    month: 1.month,
    year: 1.year
  }.freeze

  def initialize(user)
    @user = user
  end

  def top_meals
    WINDOWS.transform_values do |duration|
      range = duration.ago.to_date..Date.current
      base_scope
        .where(ate_on: range)
        .group(:name)
        .order(Arel.sql("COUNT(*) DESC"))
        .limit(3)
        .count
        .map { |name, total| { name:, total: } }
    end
  end

  def overdue_favorites(limit: 5)
    base_scope
      .select("name, MAX(ate_on) AS last_ate_on, COUNT(*) AS total_logged")
      .group(:name)
      .order("last_ate_on ASC")
      .limit(limit)
      .map do |record|
        {
          name: record.name,
          last_ate_on: record.last_ate_on.to_date,
          total_logged: record.total_logged
        }
      end
  end

  def source_distribution(range: 1.month)
    counts = base_scope.where(ate_on: range.ago.to_date..Date.current).group(:source).count
    Meal.sources.each_with_object({}) do |(name, value), acc|
      acc[name] = counts[name] || counts[value] || 0
    end
  end

  private

  attr_reader :user

  def base_scope
    user.meals
  end
end
