class TasksController < ApplicationController
  before_action :set_task, only: [:update]

  def update
    if @task.update(task_params)
      redirect_to @task.todo, notice: "Tâche mise à jour."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_task
    @task = Task.find(params[:id])
  end

  def task_params
    params.require(:task).permit(
      :title,
      :ressource_ia,
      :completed,
      :priority,
      :completed_at
    )
  end
end
