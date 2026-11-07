json.clubs @clubs do |club|
  logo_url = club.logo.attached? ? url_for(club.logo) : nil

  json.slug club.slug
  json.name club.name
  json.description club.description
  json.logo_url logo_url
  json.updated_at club.updated_at.iso8601
  json.athletes_count @count_athletes.fetch(club.id, 0)
  json.results_count @results_stats.dig(club.id, :count) || 0
end

json.meta do
  json.page @clubs.current_page
  json.total_pages @clubs.total_pages
  json.total_count @clubs.total_count
  json.per_page @clubs.limit_value
end
