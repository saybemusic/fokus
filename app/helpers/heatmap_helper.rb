module HeatmapHelper

  # ==========================================================
  #  Génération des intensités pour chaque todo d'un objectif
  # ==========================================================
  def heatmap_data_for(objective)
    return [] if objective.nil? || objective.todos.empty?

    today = Date.current

    todos = objective.todos.order(:due_date)

    intensities = todos.map do |todo|
      due = todo.due_date
      total = todo.tasks.count
      done  = todo.tasks.where(completed: true).count

      # Sécurité si pas de date
      next 0 if due.nil?

      if due > today
        0 # futur → gris

      elsif due < today
        if done == 0
          1 # rouge
        elsif done < total
          2 # orange
        else
          3 # vert
        end

      else # today
        if done == 0
          0 # gris
        elsif done < total
          2 # orange
        else
          3 # vert
        end
      end
    end

    apply_sliding_window(intensities)
  end



  # ==========================================================
  #  Fenêtre glissante (sliding window)
  #
  #  - Si moins de 30 → on retourne tout
  #  - Si plus de 30 :
  #      - Si on est dans les 20 premiers jours → jours 1 → 30
  #      - Sinon → montre les 30 jours autour de la progression
  # ==========================================================
  def apply_sliding_window(data)
    max_size = 30
    return data if data.length <= max_size

    # Trouver le dernier jour fait TOTAL ou PARTIEL
    last_active_index = data.rindex { |v| v > 0 } || 0

    # Tant que last_active_index < 20, on garde le début du programme
    if last_active_index < 20
      return data.first(max_size)
    end

    # Sinon, on suit la progression et on affiche autour
    start = last_active_index - 20
    start = 0 if start < 0

    stop = start + max_size
    stop = data.length if stop > data.length

    data[start...stop]
  end



  # ==========================================================
  #  Génération du canvas pour StimulusJS
  # ==========================================================
  def heatmap_canvas_for(objective)
    data = heatmap_data_for(objective)

    tag.canvas(
      "",
      width: 400,
      height: 90,
      data: {
        controller: "heatmap",
        heatmap_data_value: data.to_json
      },
      class: "heatmap-canvas"
    )
  end

end
