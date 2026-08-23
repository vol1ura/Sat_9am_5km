if athlete
  json.extract! athlete, :id, :name, :parkrun_code, :gender
  json.club athlete.club&.name
else
  json.name 'НЕИЗВЕСТНЫЙ'
end
