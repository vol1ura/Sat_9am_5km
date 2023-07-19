# frozen_string_literal: true

ActiveAdmin.register Contact do
  belongs_to :event

  actions :all, except: :show

  config.filters = false

  permit_params :contact_type, :event_id, :link

  index download_links: false, title: -> { t '.title', event_name: @event.name } do
    selectable_column

    column :contact_type
    column :link
    actions
  end
end
