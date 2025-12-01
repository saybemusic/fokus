class ObjectivesController < ApplicationController
  def new
    @ojective = Objective.new
  end

  def index
    @objectives = Objective.all
  end

  def show
    @objective = current_user.objectives.find(params[:id])
  end

  def create

  end

  def update

  end

  def destroy
    @objective = current_user.objectives.find(params[:id])
    @objective.destroy
  end

  private

  def objective_params
    params.require(:objective).permit
  end
end
