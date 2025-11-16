Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins %r{\Ahttps://volunteer\.s95\.\w\w\z}

    resource '/api/mobile/*',
      headers: :any,
      methods: %i[get post options head]
  end
end
