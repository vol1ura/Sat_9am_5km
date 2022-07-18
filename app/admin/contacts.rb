# frozen_string_literal: true

ActiveAdmin.register Contact do
  belongs_to :event
  includes :event

  permit_params do
    permitted = %i[contact_type event_id]
    permitted << :link if current_user.admin?
  end

  index download_links: false do
    selectable_column

    column :contact_type
    column :link
    column :event
    actions
  end
end
