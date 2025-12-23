json.athlete do
  json.extract! @athlete, :id, :name
  json.gender @athlete.male ? 'male' : 'female'
  json.best_result do
    json.total_time time_to_sec(@result.total_time) if @result
    json.date @result&.date&.iso8601
    json.position @result&.position
  end
end
