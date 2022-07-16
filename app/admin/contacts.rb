# frozen_string_literal: true

ActiveAdmin.register Contact do
  belongs_to :event
  includes :event

  permit_params :link, :contact_type, :event_id

  index download_links: false do
    selectable_column

    column :contact_type
    column :link
    column :event
    actions
  end
end
