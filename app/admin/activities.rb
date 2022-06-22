# frozen_string_literal: true

ActiveAdmin.register Activity do
  actions :all, except: :destroy

  permit_params :description, :published
  menu label: 'Забеги', priority: 2
  filter :date
  filter :published

  form title: 'Загрузка забега', partial: 'form'
end
