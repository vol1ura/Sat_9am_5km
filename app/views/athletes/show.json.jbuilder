json.athlete do
  json.extract! @athlete, :id, :name, :gender, :parkrun_code
  json.code @athlete.code
  json.home_event @athlete.event&.name
  json.club @athlete.club&.name
end

json.total_results @results.size
json.total_volunteering @volunteering.size

json.results @results do |result|
  json.date result.date.iso8601
  json.total_time result.time_string
  json.position result.position
  json.personal_best result.personal_best
  json.first_run result.first_run
  json.event result.activity.event, :code_name, :name, :town
end

json.volunteering @volunteering do |volunteer|
  json.date volunteer.date.iso8601
  json.role volunteer.role
  json.event volunteer.activity.event, :code_name, :name, :town
end
