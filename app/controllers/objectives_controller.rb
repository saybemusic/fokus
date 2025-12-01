class ObjectivesController < ApplicationController
  before_action :set_objective, only: [:show, :update, :destroy]

  def index
    @objectives = Objective.all
  end

  def show
    @objective = current_user.objectives.find(params[:id])
  end

  def create
    @article = Article.new(article_params)

    if @objective.save?
      redirect_to @objective, notice: 'Objectif créé avec succès.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @objective.update(objective_params)
      redirect_to @objective, notice: 'Objectif mis à jour avec succès.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @objective = current_user.objectives.find(params[:id])
    @objective.destroy
  end

  private

  def set_objective
    @objective = Objective.find(params[:id])
  end


  def objective_params
    params.require(:objective).permit(
      :system_prompt,
      :goal,
      :resume,
      :time_global,
      :time_due,
      :completed_at,
      :completed,
      :user_id
    )
  end
end
