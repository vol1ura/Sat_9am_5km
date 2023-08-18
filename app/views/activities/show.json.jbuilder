json.ignore_nil!
json.results do
  json.partial! 'result', collection: @results, as: :result, cached: true
end
