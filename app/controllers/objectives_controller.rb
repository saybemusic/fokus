class ObjectivesController < ApplicationController
  before_action :set_objective, only: [:show, :update, :destroy]


  def index
    @objectives = current_user.objectives
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
        LoaderJob.perform_later(@objective.id)
        @todos = Todo.all
        redirect_to @objective, notice: "Objectif créé et programme généré avec succès."
      else
        render :new, status: :unprocessable_entity
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


  def create_todos_and_tasks(objective, data)

    data["todos"].each do |todo_data|
    @todo = Todo.new(
      due_date:  Date.current + (todo_data["day"] - 1),
      title: todo_data["title"],
      description: todo_data["description"],
      )
        @todo.objective_id = objective.id
        @todo.save

          todo_data["tasks"].each do |task_data|
          @task = Task.new(
            title: task_data["description"],
            priority: task_data["priority"],
            todo_id: @todo,
            ressource_ia: task_data["ressource_ia"]
            )
              @task.todo_id = @todo.id
              @task.save
          end
      end
  end
end
