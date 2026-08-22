# frozen_string_literal: true

ActiveAdmin.register VolunteeringPosition do
  belongs_to :event

  actions :all, except: :show

  permit_params :event_id, :activity_id, :rank, :role, :number

  config.filters = false
  config.sort_order = 'rank_asc'

  breadcrumb do
    [
      link_to('главная', admin_root_path),
      link_to(event.name, admin_event_path(event)),
      link_to('волонтёрские позиции', admin_event_volunteering_positions_path(event)),
    ]
  end

  controller do
    def scoped_collection
      action_name == 'index' ? super.includes(:activity) : super
    end

    def update
      update!(notice: t('.successful')) { collection_path }
    end

    def create
      create!(notice: t('.successful')) { collection_path }
    end
  end

  index download_links: false, title: -> { t '.title', event_name: @event.name } do
    selectable_column
    column :rank
    column :number
    column(:role) { |v| human_volunteer_role v.role }
    column(:activity) { |v| v.activity ? human_activity_name(v.activity) : 'по умолчанию (все забеги)' }
    actions
  end

  form do |f|
    f.inputs do
      f.input :rank
      f.input :number
      f.input :role, as: :searchable_select
      f.input(
        :activity_id,
        as: :searchable_select,
        collection: event.activities.unpublished.order(date: :desc),
        label: 'Забег (оставьте пустым, чтобы применить ко всем забегам события)',
        include_blank: 'По умолчанию (все забеги)',
      )
    end
    f.actions
  end
end
