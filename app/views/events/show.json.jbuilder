json.updated_at @event.activities.published.maximum(:updated_at)&.iso8601
json.activities @activities do |activity|
  json.date activity.date
  json.updated_at activity.updated_at.iso8601
  json.url activity_url(activity, format: :json)
end
