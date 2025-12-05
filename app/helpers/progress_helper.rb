module ProgressHelper
  def objective_progress(objective)
    total_tasks = objective.todos.sum { |td| td.tasks.count }
    done_tasks  = objective.todos.sum { |td| td.tasks.where(completed: true).count }

    percent = total_tasks > 0 ? ((done_tasks.to_f / total_tasks) * 100).round : 0

    {
      total: total_tasks,
      done:  done_tasks,
      percent: percent
    }
  end
end
