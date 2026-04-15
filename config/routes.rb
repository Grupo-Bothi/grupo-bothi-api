Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      # Auth
      post "auth/login", to: "authentication#login"
      get  "auth/me",    to: "authentication#me"

      # Passwords
      put  "passwords/update",            to: "passwords#update"
      post "passwords/reset",             to: "passwords#reset"
      put  "passwords/update_with_token", to: "passwords#update_with_token"

      # Users
      resources :users do
        member { patch :update_active }
      end

      # Uploads
      resources :uploads, only: [:index, :show, :create, :destroy]

      # Company
      resource :company, only: [:show, :update]

      # Employees + checkin/checkout + sus asistencias
      resources :employees do
        member do
          post :checkin
          post :checkout
        end
      end

      # Asistencias (con filtros por employee, from, to)
      resources :attendances, only: [:index]

      # Inventario
      resources :products do
        resources :stock_movements, only: [:index, :create]
      end
    end
  end
end