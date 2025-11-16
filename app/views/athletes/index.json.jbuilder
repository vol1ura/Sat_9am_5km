json.athletes @athletes.includes(:event, :club) do |athlete|
  json.call(athlete, :name, :id, :code, :gender)
  json.home_event athlete.event&.name
  json.club athlete.club&.name
end
