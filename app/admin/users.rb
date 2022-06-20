# frozen_string_literal: true

ActiveAdmin.register User do
  config.comments = false

  permit_params :email, :password, :password_confirmation

  index download_links: false do
    selectable_column
    id_column
    column :email
    column :created_at
    actions
  end

  filter :email
  filter :created_at
  form do |f|
    f.inputs do
      f.input :email
      f.input :password
      f.input :password_confirmation
    end
    f.actions
  end
end
