class ObjectivesController < ApplicationController
  before_action :set_objective, only: [:show, :update, :destroy]

  SYSTEM_PROMPT = <<~PROMPT
  You are an expert planner specializing in pedagogy and learning program design.

  Your mission: create a structured learning program based on the user's information.

  User inputs:
  - Goal: objectif
  - Program duration in days: duree_programme
  - Daily available time in minutes: temps_quotidien

  Constraints:
  1. Each todo represents one day of the program.
  2. Each task is a concrete action to be completed on that day.
  3. Respect the daily maximum time constraint.
  4. The program must be progressive and pedagogical.
  5. Provide clear titles and descriptions for each todo.
  6. Each task may include a link or AI resource in ressource_ia if available.
  7. Assign a "priority" (integer) to each task to define execution order.
  8. The JSON output must be strictly valid (double quotes, no trailing commas).

  MANDATORY output format:

  {
    todos: [
      {
        day: 1,
        title: "Todo title",
        description: "Description of the day",
        tasks: [
          {
            description: "Task name",
            ressource_ia: "Link or AI resource if available",
            priority: 1
          }
        ]
      }
    ]
  }

  Generate the complete program for the total number of requested days, with detailed todos and tasks.
  Return strictly the JSON only, with no explanations or additional text.
  PROMPT

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
    @objective.system_prompt = SYSTEM_PROMPT
    # @objective.goal = params[:goal]
    # @objective.time_due = params[:time_due]
    # @objective.time_global = params[:time_global]

    if @objective.save
      program_data = generate_program_llm(
        goal: @objective.goal,
        time_global: @objective.time_global,
        time_due: @objective.time_due
        )
        create_todos_and_tasks(@objective, program_data)
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

  def generate_program_llm(goal:, time_global:, time_due:)
    ruby_llm = RubyLLM.chat
    llm_request = ruby_llm.with_instructions(SYSTEM_PROMPT)

    response = llm_request.ask({
      objectif: @objective.goal,
      duree_programme: @objective.time_due,
      temps_quotidien: @objective.time_global
      }.to_json)
        response = JSON.parse(response.content)
        JSON::ParserError
        # { "todos" => [] }
        response
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
            # ressource_ia: task_data["ressource_ia"],
            priority: task_data["priority"],
            todo_id: @todo
            )
              @task.todo_id = @todo.id
              @task.save
          end
      end
  end
end
