json.athlete do
  json.call @athlete, :code, :name, :gender
  json.home_event @athlete.event&.name
  json.volunteering do
    json.stats do
      json.general @athlete.stats['volunteers']
      json.history @volunteering_history
    end
    json.scheduled @scheduled_volunteering do |volunteering|
      json.event_name volunteering.activity.event_name
      json.date volunteering.date.to_s
      json.role volunteering.role
      json.town volunteering.activity.event.town
    end
  end
end

json.volunteer_roles Volunteer.roles.each_key do |role|
  json.value role
  json.label I18n.t("activerecord.attributes.volunteer.roles.#{role}")
end

json.session do
  json.expires_at @mobile_session.expires_at
  json.device_name @mobile_session.device_name
end
