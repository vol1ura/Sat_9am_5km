json.call(@athlete, :name, :male)
json.home_event @athlete.event&.name
json.volunteering do
  json.stats @athlete.stats['volunteers']
  json.scheduled(
    @athlete
      .volunteering
      .includes(activity: :event)
      .where(activity: { date: Date.current.. })
      .rewhere(activity: { published: false })
      .reorder(:date)
      .map { |v| { event_name: v.activity.event_name, date: v.date.to_s, role: v.role } },
  )
end
