json.call @activity, :id, :date, :number
json.published @activity.published?
json.automatic @activity.token?
json.activity_token(@capabilities[:toggle_mode] && @activity.date == Date.current ? @activity.token : nil)
json.revision @activity.updated_at.iso8601(6)
json.event @activity.event, :id, :name, :town
json.capabilities @capabilities
json.volunteer_roles Volunteer.roles.each_key do |role|
  json.value role
  json.label I18n.t("activerecord.attributes.volunteer.roles.#{role}")
end
json.volunteers @volunteers, partial: 'volunteer', as: :volunteer
json.results @results, partial: 'result', as: :result
if @capabilities[:publish]
  json.publication do
    json.partial! 'publication', activity: @activity
  end
else
  json.publication nil
end
