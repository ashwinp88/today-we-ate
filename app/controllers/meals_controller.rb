class MealsController < ApplicationController
  before_action :require_authentication!
  before_action :set_meal, only: %i[edit update destroy]

  def index
    @meals = current_user.meals.order(ate_on: :desc).limit(50)
  end

  def new
    @meal = current_user.meals.build(ate_on: Date.current, source: :home, rating: 4.0)
  end

  def create
    @meal = current_user.meals.build(meal_params)
    if @meal.save
      redirect_to home_path, notice: "Meal logged!"
    else
      flash.now[:alert] = @meal.errors.full_messages.to_sentence
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @meal.update(meal_params)
      redirect_to meals_path, notice: "Meal updated."
    else
      flash.now[:alert] = @meal.errors.full_messages.to_sentence
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @meal.destroy
    redirect_to meals_path, notice: "Meal deleted."
  end

  private

  def meal_params
    params.require(:meal).permit(:name, :source, :rating, :ate_on, :retry_in_days, :notes)
  end

  def set_meal
    @meal = current_user.meals.find(params[:id])
  end
end
