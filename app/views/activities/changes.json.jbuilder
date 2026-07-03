json.activities @activities do |activity|
  json.id activity.id
  json.date activity.date
  json.updated_at activity.updated_at.iso8601
  json.url activity_url(activity, format: :json)
  json.event activity.event, :code_name
end

json.meta do
  json.page @activities.current_page
  json.total_pages @activities.total_pages
  json.total_count @activities.total_count
  json.per_page @activities.limit_value
end
