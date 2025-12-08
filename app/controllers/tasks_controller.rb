class TasksController < ApplicationController
  before_action :set_task, except: [:update]

  def index
    @tasks = Task.all
  end

  def update
    @task = Task.find(params[:id])
    @task.update(completed: true)
    redirect_to todo_path(@task.todo.objective)
  end

  def uncomplete
    @task = Task.find(params[:id])
    @task.update(completed: false)

    respond_to do |format|
      format.turbo_stream
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
      :completed_at,
      :todo_id
    )
  end
end
