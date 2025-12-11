class FakeJob < ApplicationJob
  queue_as :default

  # pour dom_id(objective, :todos)
  include ActionView::RecordIdentifier

  SYSTEM_PROMPT = <<~PROMPT
    You are an expert planner specializing in pedagogy and learning all objectives.

    Your mission: create a structured learning program based on the user's information.

    User inputs:
    - Goal: objectif
    - Program duration in days: duree_programme
    - Daily available time in minutes: temps_quotidien
    - Optionnal notes : resume

    Constraints:
    1. Take the input user’s constraints into account and strictly respect it.
    2. Each todo represents one day of the program.
    3. Each task is a concrete action for adult to be completed on that day.
    4. Respect the daily maximum time constraint.
    5. The program must be progressive and pedagogical.
    6. Provide clear titles and descriptions for each todo.
    7. Each task should include a clear and actionable tip in ressource_ia to help the user start effectively (never give link for that).
    8. Assign a "priority" (integer) to each task to define execution order.
    9. The JSON output must be strictly valid (double quotes, no trailing commas).
    10. There should be minimum four task per todos but you can more task per todos if it's necessary.
    11. Every value should be in french

    MANDATORY output format:

    {
      "todos": [
        {
          "day": 1,
          "title": "Todo title",
          "description": "Description of the day",
          "tasks": [
            {
              "description": "Task name",
              "ressource_ia": "details/protocol",
              "priority": 1
            }
          ]
        }
      ]
    }

    Generate the complete program for the total number of requested days, with detailed todos and tasks.
    Return strictly the JSON only, with no explanations or additional text.
  PROMPT

  def perform(objective_id)
    objective = Objective.find_by(id: objective_id)
    return unless objective # au cas où il a été supprimé

    program_data = generate_program_llm(
      objective,
      goal: objective.goal,
      time_global: objective.time_global,
      time_due: objective.time_due,
      resume: objective.resume
    )

    return if program_data.blank? || program_data["todos"].blank?

    create_todos_and_tasks(objective, program_data)

    if objective.todos.count < 1
      Rails.logger.error "Erreur lors de la génération du programme, aucun todo pour l'objectif ##{objective_id}."
      return
    end

    # 🔥 Ici on envoie le Turbo Stream qui remplace le turbo_frame dom_id(@objective, :todos)
    Turbo::StreamsChannel.broadcast_replace_to(
      objective,
      target: dom_id(objective, :todos),
      partial: "objectives/todos",
      locals: { objective: objective }
    )

    Rails.logger.info "Programme généré pour Objective ##{objective_id}"
  rescue JSON::ParserError => e
    Rails.logger.error "Erreur JSON pour Objective ##{objective_id}: #{e.message}"
  end

  private

  def generate_program_llm(objective, goal:, time_global:, time_due:, resume:)
    ruby_llm = RubyLLM.chat
    llm_request = ruby_llm.with_instructions(SYSTEM_PROMPT)

    response = llm_request.ask({
      objectif: goal,
      duree_programme: time_due,
      temps_quotidien: time_global,
      resume: resume
    }.to_json)

    JSON.parse(response.content)
  end

  def create_todos_and_tasks(objective, data)
    data["todos"].each do |todo_data|
      todo = Todo.create!(
        objective: objective,
        due_date: Date.current + (todo_data["day"].to_i - 1),
        title: todo_data["title"],
        description: todo_data["description"]
      )

      todo_data["tasks"].each do |task_data|
        Task.create!(
          todo: todo,
          title: task_data["description"],
          priority: task_data["priority"],
          ressource_ia: task_data["ressource_ia"]
        )
      end
    end
  end
end
