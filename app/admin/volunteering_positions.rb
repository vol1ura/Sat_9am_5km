# frozen_string_literal: true

ActiveAdmin.register VolunteeringPosition do
  belongs_to :event

  actions :all, except: :show

  permit_params :event_id, :rank, :role, :number

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
    actions
  end

  form do |f|
    f.inputs do
      f.input :rank
      f.input :number
      f.input :role
    end
    f.actions
  end
end
