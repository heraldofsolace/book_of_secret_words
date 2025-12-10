require "sidekiq/web"

Rails.application.routes.draw do
  mount Sidekiq::Web => "/sidekiq"
  get "users/check_username"
  devise_for :users

  # Public profile keeps the same URL: /users/:username
  get "/users/:username",
      to: "static_pages#public_profile",
      as: :public_profile,
      constraints: { username: /[A-Za-z0-9_\.]+/ }

  # User-scoped anonymous messages (new/create)
  scope "/users/:username", constraints: { username: /[A-Za-z0-9_\.]+/ } do
    get  "message", to: "messages#new",    as: :new_user_message
    post "message", to: "messages#create", as: :user_message
  end

  # Owner-side message management
  resources :messages, only: [:update, :destroy]

  # Dashboard
  get "/dashboard", to: "static_pages#dashboard", as: :dashboard

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  get "/check_username", to: "users#check_username"

  # Home
  root to: "static_pages#home"
end
