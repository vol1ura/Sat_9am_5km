json.total_time result.time_string
json.position result.position
json.athlete { json.partial! 'athlete', athlete: result.athlete }
