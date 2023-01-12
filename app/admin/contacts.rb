# frozen_string_literal: true

ActiveAdmin.register Contact do
  belongs_to :event

  config.filters = false

  permit_params :contact_type, :event_id, :link

  index download_links: false, title: -> { "Контакты #{@event.name}" } do
    selectable_column

    column :contact_type
    column :link
    actions
  end
end
