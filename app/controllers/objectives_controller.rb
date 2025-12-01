class ObjectivesController < ApplicationController
  before_action :set_objective, only: [:show, :update, :destroy]

SYSTEM_PROMPT = "Tu es un planificateur expert en pédagogie et en création de programmes d'apprentissage.

Ta mission : créer un programme structuré à partir des informations de l'utilisateur.

Entrées utilisateur :
- Objectif : {{objectif}}
- Durée du programme en jours : {{duree_programme}}
- Temps disponible par jour en minutes : {{temps_quotidien}}

Contraintes :
1. Chaque "todo" représente une journée du programme.
2. Chaque "task" est une action concrète à réaliser ce jour-là.
3. Respecte le temps quotidien maximum.
4. Le programme doit être progressif et pédagogique.
5. Fournis des titres clairs et des descriptions pour chaque todo.
6. Chaque task peut contenir un lien ou ressource IA dans "ressource_ia" si disponible.
7. Assigne un "priority" à chaque task (entier) pour trier l'ordre d'exécution.
8. Le JSON doit être **strictement valide** (guillemets doubles, pas de trailing commas).

Format de sortie OBLIGATOIRE :

{
  "todos": [
    {
      "jour": 1,
      "titre": "Titre du todo",
      "description": "Description de la journée",
      "tasks": [
        {
          "description": "Nom de la tâche",
          "ressource_ia": "Lien ou info IA si disponible",
          "priority": 1
        }
      ]
    }
  ]
}

Génère le programme complet pour le nombre de jours demandé, avec des todos et tasks détaillés.
Ne renvoie **strictement que le JSON**, sans explications ni texte additionnel."


  def index
    @objectives = current_user.objectives
  end

  def show
  end

  def new
    @objective = current_user.objectives.new
  end

  def create
    @objective = current_user.objectives.new(objective_params)
    @objective.system_prompt = SYSTEM_PROMPT

    if @objective.save
      program_data = generate_program_llm(
        goal: @objective.goal,
        time_global: @objective.time_global,
        time_due: @objective.time_due
      )

      create_todos_and_tasks(@objective, program_data)

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
      :time_due,
      :completed_at,
      :completed
    )
  end

  def generate_program_llm(goal:, time_global:, time_due:)
    client = OpenAI::Client.new(access_token: ENV["OPENAI_API_KEY"])

    prompt = SYSTEM_PROMPT
             .gsub("{{objectif}}", goal)
             .gsub("{{duree_programme}}", time_global.to_s)
             .gsub("{{temps_quotidien}}", time_due.to_s)

    response = client.chat(
      parameters: {
        model: "gpt-4.1",
        messages: [{ role: "user", content: prompt }]
      }
    )

    content = response.dig("choices", 0, "message", "content")
    JSON.parse(content)
  rescue JSON::ParserError => e
    Rails.logger.error("Erreur parsing LLM : #{e.message}")
    {}
  end

  def create_todos_and_tasks(objective, program_data)
    return unless program_data["todos"].present?

    program_data["todos"].each do |todo_data|
      todo = objective.todos.create!(
        title: todo_data["titre"] || "Jour #{todo_data['jour']}",
        description: todo_data["description"]
      )

      todo_data["tasks"]&.each do |task_data|
        todo.tasks.create!(
          title: task_data["description"],
          ressource_ia: task_data["ressource_ia"],
          completed: false,
          priority: task_data["priority"]
        )
      end
    end
  end
end
