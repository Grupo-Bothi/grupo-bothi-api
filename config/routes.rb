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

      # Company (usuario actual) + Companies (super_admin: CRUD global)
      resource  :company,   only: [:show, :update]
      resources :companies, only: [:index, :show, :create, :update, :destroy]

      # Employees + checkin/checkout + sus asistencias
      resources :employees do
        member do
          post :checkin
          post :checkout
        end
      end

      # Asistencias (con filtros por employee, from, to)
      resources :attendances, only: [:index]

      # Inventario / Menú
      resources :products do
        collection { get :menu }
        resources :stock_movements, only: [:index, :create]
      end

      resources :units, only: [:index]

      resources :work_orders do
        member do
          patch :update_status
          post   'items',                  to: 'work_orders#create_item',  as: :create_item
          patch  'items/:item_id',         to: 'work_orders#update_item',  as: :update_item
          delete 'items/:item_id',         to: 'work_orders#destroy_item', as: :destroy_item
          patch  'items/:item_id/toggle',  to: 'work_orders#toggle_item',  as: :toggle_item
        end
      end
      
    end
  end
end