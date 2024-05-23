json.athlete do
  json.call(@athlete, :code, :name, :gender)
  json.best_result do
    if @result
      json.total_time time_to_sec @result.total_time
      json.date @result.activity.date.iso8601
      json.position @result.position
    else
      json.null!
    end
  end
end
