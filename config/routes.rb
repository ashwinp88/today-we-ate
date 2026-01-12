Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Chrome devtools probes this well-known path; return 404 without raising errors.
  get "/.well-known/appspecific/com.chrome.devtools.json", to: proc { [404, { "Content-Type" => "application/json" }, ['{"error":"not_found"}']] }

  root "dashboard#show"

  resources :meals, only: %i[index new create]

  match "/auth/:provider/callback", to: "sessions#create", via: %i[get post]
  get "/auth/failure", to: "sessions#failure"
  delete "/sign_out", to: "sessions#destroy", as: :sign_out

  # Email/password auth
  get "/login", to: "sessions#new", as: :login
  post "/login", to: "sessions#email", as: :email_login
  get "/signup", to: "users#new", as: :signup
  post "/signup", to: "users#create"
  post "/preauth", to: "preauths#create", as: :preauth
end
