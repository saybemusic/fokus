class TodosController < ApplicationController
  def show
    @objective = Objective.find(params[:id])
    @todo_yesterday = ""
    @todo = ""
    @taskDone = 0
    todo_of_day(@objective)
    numberOfTask = @todo.tasks.count
    @todo.tasks.each do |task|
      @taskDone += 1 if task.completed
      @todo.update(completed: true) if numberOfTask == @taskDone
      @todo_just_completed = true
    end
    todo_of_day(@objective)
    # raise
  end

    # si todos du jour précedent (todos.completed_at), donc passer a todos suivante
    # sinon reprendre la todo non terminée

  def update
    @objective = Objective.find(params[:id])
    @todo_yesterday = ""
    @todo = ""
    todo_of_day(@objective)
    @todo.task.update(completed: true)

  end

  private

  def todo_of_day(objective)
    objective.todos.each_with_index do |todo, index|
      if todo.completed
        @todo_yesterday = todo
        if index == objective.todos.length - 1
          @todo = todo
          return
        end
      else
        @todo = todo
        return
      end
    end
  end

  def todos_params
    params.require(:todo).permit(
      :title,
      :description,
      :completed,
      :due_date,
      :completed_at,
    )
  end
end
