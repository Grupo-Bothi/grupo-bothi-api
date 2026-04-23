host_options =
  if Rails.env.production?
    { host: "www.grupobothi.com", protocol: "https" }
  else
    { host: "localhost", port: 3000 }
  end

Rails.application.routes.default_url_options.merge!(host_options)
