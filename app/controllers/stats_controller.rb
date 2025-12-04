class StatsController < ApplicationController
  before_action :authenticate_user!

  def index
    user = current_user

    # --- OBJECTIFS ---
    @objectives = user.objectives
    @objectives_count = @objectives.count
    @objectives_completed = @objectives.where(completed: true).count

    # --- TASKS ---
    @tasks = Task.joins(todo: :objective).where(objectives: { user_id: user.id })
    @tasks_total = @tasks.count
    @tasks_done = @tasks.where(completed: true).count

    # --- TASKS COMPLÉTÉES AVEC completed_at NON NIL ---
    @completed_tasks = @tasks.where(completed: true).where.not(completed_at: nil)

    # --- JOURNÉES ACTIVES (pour la heatmap générale) ---
    @days_visited = @completed_tasks.group_by { |t| t.completed_at.to_date }
    @days_visited_count = @days_visited.keys.count

    # --- STREAK GLOBAL ---
    @streak = calculate_streak(@days_visited.keys.sort)

    # --- OBJECTIF PRÉFÉRÉ (plus de tâches faites, sinon dernier créé) ---
    favorite_by_tasks = @objectives.max_by do |o|
      o.todos.sum { |td| td.tasks.where(completed: true).count }
    end

    total_tasks_done = @objectives.sum do |o|
      o.todos.sum { |td| td.tasks.where(completed: true).count }
    end

    @favorite_objective = if total_tasks_done > 0
      favorite_by_tasks
    else
      @objectives.order(created_at: :desc).first
    end

    # --- PRODUCTIVITÉ QUOTIDIENNE MOYENNE ---
    @productivity_avg = if @days_visited_count > 0
      (@tasks_done.to_f / @days_visited_count).round(2)
    else
      0
    end

    # --- JOUR LE PLUS PRODUCTIF ---
    @tasks_by_day = @completed_tasks.group_by { |t| t.completed_at.to_date }
    max_day = @tasks_by_day.max_by { |_, tasks| tasks.size }
    @most_productive_day = max_day&.first
    @most_productive_count = max_day ? max_day.last.size : 0

    # --- TÂCHES EN RETARD ---
    @late_tasks = @completed_tasks.select do |task|
      task.todo.due_date &&
      task.completed_at.to_date > task.todo.due_date
    end

    @late_percentage = @tasks_total > 0 ? ((@late_tasks.count.to_f / @tasks_total) * 100).round : 0

    # --- HEURE LA PLUS FRÉQUENTE D’UTILISATION ---
    @usage_hours = @completed_tasks.map { |t| t.completed_at.hour }
    @favorite_hour = @usage_hours.group_by(&:itself).max_by { |_, arr| arr.size }&.first

    # --- TEMPS TOTAL D’APPRENTISSAGE ESTIMÉ ---
    avg_time = @objectives.average(:time_global).to_i rescue 0
    @total_learning_time = @tasks_done * avg_time

    # --- PROGRESSION MOYENNE PAR OBJECTIF (%) ---
    @progressions = @objectives.map do |o|
      total_tasks = o.todos.sum { |td| td.tasks.count }
      done_tasks  = o.todos.sum { |td| td.tasks.where(completed: true).count }

      total_tasks > 0 ? ((done_tasks.to_f / total_tasks) * 100).round : 0
    end

    @avg_progression = @progressions.count > 0 ? (@progressions.sum / @progressions.count).round : 0

    # --- OBJECTIF LE PLUS RAPIDE & LE PLUS LENT (seulement ceux complétés) ---
    completed_objectives = @objectives.where.not(completed_at: nil)

    @fastest_objective = completed_objectives.min_by do |o|
      o.completed_at.to_date - o.created_at.to_date
    end

    @slowest_objective = completed_objectives.max_by do |o|
      o.completed_at.to_date - o.created_at.to_date
    end
  end

  # ----------------------------------------------------
  # 🔥 HEATMAP PAR OBJECTIF
  # Chaque objectif => tableau d'intensités par jour du programme
  # 0 = blanc (futur ou jour actuel sans tâche)
  # 1 = rouge (jour passé, 0 tâche faite)
  # 2 = orange (jour passé ou actuel, partiellement complété)
  # 3 = vert (toutes les tâches du jour faites)
  # ----------------------------------------------------
def objectives
  @objectives = current_user.objectives.includes(todos: :tasks)
  @heatmaps = {}

  today = Date.current

  @objectives.each do |objective|
    todos = objective.todos.order(:due_date)

    data = todos.map do |todo|
      due_date = todo.due_date
      total    = todo.tasks.count
      done     = todo.tasks.where(completed: true).count

      if due_date.nil?
        0
      elsif due_date > today
        0
      elsif due_date == today
        if done == 0
          0   # jour actuel → blanc
        elsif done < total
          2   # orange
        else
          3   # vert
        end
      else
        if total == 0 || done == 0
          1   # rouge
        elsif done < total
          2   # orange
        else
          3   # vert
        end
      end
    end

    @heatmaps[objective.id] = data
  end
end

  private

  # Calcul du streak (suite de jours consécutifs)
  def calculate_streak(days)
    return 0 if days.empty?

    streak = 1
    (1...days.length).reverse_each do |i|
      if days[i] == days[i - 1] + 1
        streak += 1
      else
        break
      end
    end

    streak
  end
end
