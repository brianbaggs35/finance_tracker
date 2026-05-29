Rails.application.routes.draw do
  post "/auth/login", to: "auth#login"
  post "/auth/refresh", to: "auth#refresh"
  delete "/auth/logout", to: "auth#logout"

  resources :transactions
end
