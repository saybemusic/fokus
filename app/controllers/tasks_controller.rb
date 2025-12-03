class TasksController < ApplicationController
  before_action :set_task, except: [:update]

  def index
    @tasks = Task.all
  end

  def update
    @objective = Objective.find(params[:id])
    @todo = ""
    todo_of_day(@objective)
    @task = Task.where(id:params[:task])
    @task.update(completed: true)
    redirect_to todo_path(@objective)
    # raise
  end

  private

  def set_task
    @task = Task.find(params[:id])
  end

  def todo_of_day(objective)
    objective.todos.each do |todo|
      if todo.completed
        @todo_yesterday = todo
      else
        @todo = todo
        return
      end
    end
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
