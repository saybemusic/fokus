Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  get "uikit" => "pages#uikit"
  # Defines the root path route ("/")
  # root "posts#index"
  devise_for :users

  root to: "pages#home"

  resources :objectives

  resources :todos, only: [:show]

  resources :tasks, only: [:index, :update]

  get "todos/:id/next_day", to: "todos#next_day", as: :next_day

  get "/stats", to: "stats#index", as: :stats

  get "/stats/objectives", to: "stats#objectives", as: :stats_objectives

end
