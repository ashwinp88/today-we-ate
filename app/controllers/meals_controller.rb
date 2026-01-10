class MealsController < ApplicationController
  before_action :require_authentication!

  def index
    @meals = current_user.meals.order(ate_on: :desc).limit(50)
  end

  def new
    @meal = current_user.meals.build(ate_on: Date.current, source: :home)
  end

  def create
    @meal = current_user.meals.build(meal_params)
    if @meal.save
      redirect_to root_path, notice: "Meal logged!"
    else
      flash.now[:alert] = @meal.errors.full_messages.to_sentence
      render :new, status: :unprocessable_entity
    end
  end

  private

  def meal_params
    params.require(:meal).permit(:name, :source, :rating, :ate_on, :retry_in_days, :notes)
  end
end
