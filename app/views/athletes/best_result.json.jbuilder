json.athlete do
  json.extract! @athlete, :id, :name, :gender
  json.best_result do
    json.total_time @result.total_time if @result
    json.date @result&.date&.iso8601
    json.position @result&.position
  end
end
