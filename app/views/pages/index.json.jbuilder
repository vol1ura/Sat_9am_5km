json.events Event.all do |event|
  json.extract! event, :active, :town, :name, :place
  json.url event_url(event.code_name, format: :json)
end
