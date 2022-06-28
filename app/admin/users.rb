# frozen_string_literal: true

ActiveAdmin.register User do
  config.comments = false
  actions :all, except: :destroy

  permit_params do
    permitted = %i[first_name last_name password password_confirmation]
    permitted << :role if current_user.admin?
  end

  index download_links: false do
    selectable_column
    column :email
    column :first_name
    column :last_name
    column :role
    column :created_at
    actions
  end

  filter :email
  filter :first_name
  filter :last_name

  show { render 'show', user: user }

  form do |f|
    f.inputs do
      # f.input :email
      f.input :first_name
      f.input :last_name
      f.input :password
      f.input :password_confirmation
      f.input :role if current_user.admin?
    end
    f.actions
  end
end
