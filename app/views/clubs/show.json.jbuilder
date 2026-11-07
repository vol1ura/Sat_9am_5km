json.club do
  json.slug @club.slug
  json.name @club.name
end

json.athletes @athletes do |athlete|
  json.id athlete.id
  json.name athlete.name
end
