json.array! @events.where('latitude IS NOT NULL AND longitude IS NOT NULL').unscope(:order) do |event|
  json.extract! event, :active, :name, :slogan, :code_name, :latitude, :longitude
end
