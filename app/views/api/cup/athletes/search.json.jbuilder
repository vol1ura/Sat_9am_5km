json.athletes @athletes do |athlete|
  json.call(athlete, :id, :code, :name, :gender)
  json.home_event_code athlete.event&.code_name
  json.home_event_name athlete.event&.name
  json.club_name athlete.club&.name
  json.runs_count athlete.stats.dig('results', 'count').to_i
  json.volunteering_by_role(@volunteering_by_role[athlete.id] || {})
end
