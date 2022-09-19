json.total_time human_result_time(result.total_time)
json.position result.position
json.athlete do
  if result.athlete_id
    json.extract! result.athlete, :id, :name, :parkrun_code, :gender
    json.club result.athlete.club&.name
  else
    json.name Athlete::NOBODY
  end
end
