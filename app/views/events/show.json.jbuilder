json.activities @event.activities.published do |activity|
  json.date activity.date
  json.url activity_url(activity, format: :json)
end
