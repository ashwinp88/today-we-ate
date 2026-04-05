Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  get "/.well-known/appspecific/com.chrome.devtools.json", to: proc {
    [ 404, { "Content-Type" => "application/json" }, [ '{"error":"not_found"}' ] ]
  }

  root to: redirect("/landing")

  get "/home", to: "dashboard#show", as: :home
  get "/insights", to: "insights#show", as: :insights
  get "/people", to: "users#index", as: :people

  resources :users, only: %i[new create] do
    resource :follow, only: %i[create destroy]
  end

  resources :meals, only: %i[index new create edit update destroy] do
    resource :meal_like, only: %i[create destroy]
    resources :meal_comments, only: :create
  end

  post "/recommendations/select", to: "recommendation_selections#create", as: :recommendation_selection

  match "/auth/:provider/callback", to: "sessions#create", via: %i[get post]
  get "/auth/failure", to: "sessions#failure"
  delete "/sign_out", to: "sessions#destroy", as: :sign_out

  get "/login", to: "sessions#new", as: :login
  post "/login", to: "sessions#email", as: :email_login
  get "/landing", to: "signups#show", as: :landing
  get "/signup", to: redirect("/landing")
  get "/signup/email", to: "users#new", as: :email_signup
  post "/signup/email", to: "users#create"
  post "/preauth", to: "preauths#create", as: :preauth
end
