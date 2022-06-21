# frozen_string_literal: true

ActiveAdmin.register User do
  config.comments = false

  permit_params :first_name, :last_name, :male, :parkrun_id, :email, :password, :password_confirmation

  index download_links: false do
    selectable_column
    id_column
    column :email
    column :first_name
    column :last_name
    column :parkrun_id
    column :male
    column :created_at
    actions
  end

  filter :email
  filter :male
  filter :parkrun_id
  filter :created_at

  form do |f|
    f.inputs do
      f.input :male, label: 'Мужчина'
      f.input :first_name
      f.input :last_name
      f.input :parkrun_id, label: 'Паркрановский номер'
      f.input :email
      # f.input :password
      # f.input :password_confirmation
    end
    f.actions
  end
end
