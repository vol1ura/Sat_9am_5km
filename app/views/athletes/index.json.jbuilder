if can? :read, Athlete
  json.athletes @athletes do |athlete|
    json.call(athlete, :name, :id, :code, :club)
    json.home_event athlete.event&.name
  end
end
