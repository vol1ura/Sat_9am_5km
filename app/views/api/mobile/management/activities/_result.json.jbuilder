json.call result, :id, :position
json.total_time result.time_string
if result.athlete
  json.athlete { json.partial! 'athlete', athlete: result.athlete }
else
  json.athlete nil
end
