json.runs @runs do |result|
  json.code @codes_by_athlete_id[result.athlete_id]
  json.athlete_id result.athlete_id
  json.activity_id result.activity_id
  json.date result.date
  json.total_time result.time_string
  json.event result.activity.event, :id, :code_name, :name
end
