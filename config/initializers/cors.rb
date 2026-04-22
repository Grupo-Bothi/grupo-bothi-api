# config/initializers/cors.rb
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins ENV.fetch("FRONTEND_URL", "FRONTEND_URL_UI", "http://localhost:4200")

    resource "*",
      headers:  :any,
      methods:  [:get, :post, :put, :patch, :delete, :options, :head],
      expose:   ["Authorization"]
  end
end