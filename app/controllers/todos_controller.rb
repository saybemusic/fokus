class TodosController < ApplicationController
  def show
    # @objective = Objective.find(params[:id])
    @todo = Todo.find(params[:id])
    @todo_yesterday = ""
    # @todo = ""
    @objective = @todo.objective
    # @taskDone = 0
    # @todoDone = 0
    # todo_of_day(@objective)
    # numberOfTask = @todo.tasks.count
    # numberOfTodo = @objective.todos.count
    # @todo_just_completed = false
    @objective_completed = false
    tasks = @todo.tasks
    if tasks.count == tasks.where(completed: true).count
      @todo_just_completed = true
    end

    todos = @objective.todos

    if todos.count == todos.where(completed: true).count
      @objective_completed = true
    end
    # @todo.tasks.each do |task|
    #   @taskDone += 1 if task.completed
    #   if numberOfTask == @taskDone
    #     @todo.update(completed: true)
    #     @todo_just_completed = true
    #   else
    #     @todo.update(completed: false)
    #     @todo_just_completed = false
    #   end
    # end

    # @objective.todos.each do |todo|
    #   @todoDone += 1 if todo.completed
    #   if numberOfTodo == @todoDone
    #     @objective.update(completed: true)
    #     @objective_completed = true
    #   else
    #     @objective_completed = false
    #   end
    # end
  end

  # def update
  #   @objective = Objective.find(params[:id])
  #   @todo_yesterday = ""
  #   @todo = ""
  #   todo_of_day(@objective)
  #   @todo.task.update(completed: true)
  # end

  def next_day
    @todo = Todo.find(params[:id])
    @objective = @todo.objective
    @todo = @objective.todos.order(:due_date).find_by(completed: false)
    # todo_of_day(@objective)
    redirect_to todo_path(@todo)
  end

  private

  # def todo_of_day(objective)
  #   objective.todos.each_with_index do |todo, index|
  #     if todo.completed
  #       @todo_yesterday = todo
  #       if index == objective.todos.length - 1
  #         @todo = todo
  #         return
  #       end
  #     else
  #       @todo = todo
  #       return
  #     end
  #   end
  # end

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
