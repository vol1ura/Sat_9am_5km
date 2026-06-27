json.ignore_nil!
json.date @activity.date.strftime('%d.%m.%Y')
json.event @activity.event, :name, :code_name, :town
json.results do
  json.partial!(
    'result',
    collection: @results,
    as: :result,
    cached: ->(result) { locale_cache_key(result, result.athlete) },
  )
end
json.volunteers do
  json.partial!(
    'volunteer',
    collection: @volunteers,
    as: :volunteer,
    cached: ->(volunteer) { locale_cache_key(volunteer, volunteer.athlete) },
  )
end
