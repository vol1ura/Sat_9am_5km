json.club do
  json.slug @club.slug
  json.name @club.name
  json.description @club.description
  json.logo_url url_for(@club.logo) if @club.logo.attached?
end

json.athletes_count @athletes.length
json.total_results_count @total_results_count
json.total_volunteering_count @total_volunteering_count

json.athletes @athletes do |athlete|
  json.id athlete.id
  json.name athlete.name
  json.results_count athlete.results_count
  json.personal_best athlete.personal_best
  json.volunteering_count @count_volunteering.fetch(athlete.id, 0)
end
