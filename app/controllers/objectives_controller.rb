class ObjectivesController < ApplicationController
  before_action :set_objective, only: [:show, :update, :destroy]




  def index
    @objectives = current_user.objectives.order(created_at: :desc)
  end


  def new
    @user = current_user
    @objective = current_user.objectives.new
  end

  def show
    @objective = Objective.find(params[:id])
  end

  def create
    @objective = Objective.new(objective_params)
    @objective.user = current_user



    if @objective.save
      FakeJob.perform_later(@objective)
      redirect_to @objective, notice: "Objectif créé et programme généré avec succès."

      respond_to do |format|
        format.html { redirect_to @objective, notice: "Objectif créé et programme généré avec succès." }
        format.turbo_stream
      end
    else
      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    if @objective.update(objective_params)
      redirect_to @objective, notice: "Objectif mis à jour avec succès."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @objective.destroy
    redirect_to objectives_path, notice: "Objectif supprimé."
  end

  private

  def set_objective
    @objective = current_user.objectives.find(params[:id])
  end

  def objective_params
    params.require(:objective).permit(
      :goal,
      :resume,
      :time_global,
      :time_due
      )
  end


end
