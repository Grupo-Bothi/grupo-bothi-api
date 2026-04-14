Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
  namespace :api do
    namespace :v1 do
      # Authentication routes
      post "/auth/login", to: "authentication#login"

      # User routes
      resources :users do
        member do
          patch :update_active
        end
      end

      # Password routes
      scope "/passwords" do
        put "/update", to: "passwords#update"                    # Update password for authenticated user
        post "/reset", to: "passwords#reset"                      # Send password reset email
        put "/update_with_token", to: "passwords#update_with_token" # Update password using reset token
      end

      # Upload routes
      post "/uploads", to: "uploads#create"
      delete "/uploads/:id", to: "uploads#destroy"
    end
  end
end
