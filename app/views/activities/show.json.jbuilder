json.ignore_nil!
json.date @activity.date.strftime('%d.%m.%Y')
json.event @activity.event, :name, :code_name, :town
json.results do
  json.partial! 'result', collection: @results, as: :result, cached: true
end
