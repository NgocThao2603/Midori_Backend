require "devise"
require "sidekiq/web"

Rails.application.routes.draw do
  mount Sidekiq::Web => "/sidekiq"
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
    resources :audio_files, only: [ :index ]
    resource :point, only: [ :show, :update ]
    resources :lesson_statuses, only: [ :index ]
    resources :test_attempts, only: [ :index, :show, :create ] do
      resources :test_answers, only: [ :index ]
      post "test_answers/update_or_create", to: "test_answers#update_or_create"
      post "submit", on: :member
    end
    resources :user_daily_activities, only: [ :index ] do
      collection do
        patch :mark_studied
        patch :update_point
      end
    end

    get "lessons/:lesson_id/tests", to: "tests#by_lesson"
    get "users", to: "users#profile"
    get "vocabularies/lesson/:lesson_id", to: "vocabularies#by_lesson"
    get "lesson_meanings/lesson/:lesson_id", to: "lesson_meanings#index"
    get "/rankings/overall", to: "users#overall_ranking"
    get "/rankings/level", to: "users#level_ranking"
    patch "lesson_statuses/:id", to: "lesson_statuses#update"
    patch "users", to: "users#update"
  end
  get "up" => "rails/health#show", as: :rails_health_check
end
