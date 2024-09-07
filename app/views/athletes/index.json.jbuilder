json.athletes @athletes.includes(:event) do |athlete|
  json.call(athlete, :name, :id, :code, :gender)
  json.home_event athlete.event&.name
end
