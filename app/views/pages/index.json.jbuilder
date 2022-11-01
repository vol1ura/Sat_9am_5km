sql = 'exists (select 1 from activities where activities.event_id = events.id and activities.published = true)'
json.events Event.unscope(:order).where(sql) do |event|
  json.extract! event, :active, :town, :name, :place
  json.url event_url(event.code_name, format: :json)
end
