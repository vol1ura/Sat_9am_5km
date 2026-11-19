json.athletes @athletes do |athlete|
  runs = athlete.stats.dig('results', 'count').to_i
  vols = runs.zero? ? @main_role_counts[athlete.id].to_i : athlete.stats.dig('volunteers', 'count').to_i

  json.call(athlete, :id, :code, :name, :gender)
  json.home_event_code athlete.event&.code_name
  json.home_event_name athlete.event&.name
  json.club_name athlete.club&.name
  json.runs_count runs
  json.volunteering_count vols
end