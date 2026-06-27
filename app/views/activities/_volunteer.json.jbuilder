json.role volunteer.role
json.athlete do
  json.extract! volunteer.athlete, :id, :name, :parkrun_code, :gender
  json.club volunteer.athlete.club&.name
end
