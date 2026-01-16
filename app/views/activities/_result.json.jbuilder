json.total_time result.time_string
json.position result.position
json.athlete do
  if result.athlete_id
    json.extract! result.athlete, :id, :name, :parkrun_code, :gender
    json.club result.athlete.club&.name
  else
    json.name 'НЕИЗВЕСТНЫЙ'
  end
end
