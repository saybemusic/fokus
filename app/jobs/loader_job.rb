class LoaderJob < ApplicationJob
  queue_as :default

  # Pour pouvoir utiliser dom_id(objective, :todos)
  include ActionView::RecordIdentifier

  SYSTEM_PROMPT = <<~PROMPT
  You are an expert planner specializing in pedagogy and learning all objectives.

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
  6. Every task should come with a helpful tip in ressource_ia to guide the user (e.g. "Search on Google: How to…" or "This website can help you").
  7. Assign a "priority" (integer) to each task to define execution order.
  8. The JSON output must be strictly valid (double quotes, no trailing commas).
  9. There should be minimum four task per todos but you can more task per todos if it's necessary.
  10. Every value should be in french

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
    objective = Objective.find(objective_id)

    ruby_llm = RubyLLM.chat
    llm_request = ruby_llm.with_instructions(SYSTEM_PROMPT)

    # 🔥 Appel à l'IA
    response = llm_request.ask({
      objectif:        objective.goal,
      duree_programme: objective.time_due,
      temps_quotidien: objective.time_global
    }.to_json)

    data = JSON.parse(response.content)

    # 🔥 Création des todos + tasks
    create_todos_and_tasks(objective, data)

    # 🔥 HTML qui remplace le contenu du turbo_frame (même structure que ta vue)
    html = ApplicationController.render(
      inline: <<-'ERB',
        <div class="programmes-main-card">
          <div class="programmes-cards-scroll">
            <% objective.todos.order(:due_date).each do |todo| %>
              <div class="programmes-carte"
                   data-completed="<%= todo.completed %>">
                <div class="programmes-carte-header"
                     style="background-image: url('<%= image_path("backgroundHome.png") %>');
                            background-size: cover;">
                  <%= todo.completed ?
                    "Jour #{todo.to_ordered_day} : Terminé :coche_trait_plein:" :
                    "Jour #{todo.to_ordered_day} : #{todo.title}" %>
                </div>
                <div class="programmes-carte-body">
                  <p><%= todo.completed ? todo.title : todo.description %></p>
                </div>
              </div>
            <% end %>
          </div>

          <div class="btn-back">
            <%= link_to "Retour aux objectifs", objectives_path, class: "bouton" %>
          </div>
        </div>
      ERB
      locals: { objective: objective }
    )

    # 🔥 Turbo Stream : remplace <turbo-frame id="objective_XX_todos">
    Turbo::StreamsChannel.broadcast_replace_to(
      objective,
      target: dom_id(objective, :todos),
      html: html
    )

  rescue JSON::ParserError => e
    Rails.logger.error "❌ JSON Parser Error pour objective #{objective_id}: #{e.message}"
  rescue => e
    Rails.logger.error "❌ ERREUR dans LoaderJob : #{e.message}"
  end

  private

  def create_todos_and_tasks(objective, data)
    data["todos"].each do |todo_data|
      todo = Todo.create!(
        due_date:    Date.current + (todo_data["day"].to_i - 1),
        title:       todo_data["title"],
        description: todo_data["description"],
        objective:   objective
      )

      todo_data["tasks"].each do |task_data|
        Task.create!(
          title:        task_data["description"],
          priority:     task_data["priority"].to_i,
          ressource_ia: task_data["ressource_ia"],
          todo:         todo
        )
      end
    end
  end
end
