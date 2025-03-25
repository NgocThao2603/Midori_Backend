Rails.application.routes.draw do
  namespace :api do
    post "register", to: "auth#register"
    post "login", to: "auth#login"

    resources :chapters, only: [ :index ] do
      resources :lessons, only: [ :index ]
    end

    get "profile", to: "users#profile"
    get "vocabularies/lesson/:lesson_id", to: "vocabularies#by_lesson"
  end
  get "up" => "rails/health#show", as: :rails_health_check
end
