require "devise"

Rails.application.routes.draw do
  devise_for :users,
    path: "api",
    path_names: {
      sign_in: "login",
      sign_out: "logout",
      registration: "register"
    },
    controllers: {
      registrations: "api/registrations",
      sessions: "api/sessions"
    },
    defaults: { format: :json }

  namespace :api, defaults: { format: :json } do
    post "/check_existing", to: "auth#check_existing"

    resources :chapters, only: [ :index ] do
      resources :lessons, only: [ :index ]
    end

    resources :questions, only: [ :index ]

    get "profile", to: "users#profile"
    get "vocabularies/lesson/:lesson_id", to: "vocabularies#by_lesson"
    get "lesson_statuses", to: "lesson_statuses#index"
  end
  get "up" => "rails/health#show", as: :rails_health_check
end
