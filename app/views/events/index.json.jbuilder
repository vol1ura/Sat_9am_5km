json.array! @events.unscope(:order) do |event|
  json.extract! event, :active, :name, :slogan, :code_name, :latitude, :longitude
end
