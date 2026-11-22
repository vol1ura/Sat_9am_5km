json.call volunteer, :id, :role, :comment
json.athlete { json.partial! 'athlete', athlete: volunteer.athlete }
