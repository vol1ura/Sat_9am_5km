# frozen_string_literal: true

ActiveAdmin.register Badge do
  menu priority: 80
  actions :all, except: :destroy

  permit_params :name, :conditions, :received_date, :image

  filter :kind, as: :select, collection: Badge.kinds
  filter :name
  filter :conditions
  filter :received_date

  index download_links: false do
    selectable_column
    column(:kind) { |b| kind_of_badge b }
    column :name
    column :received_date
    column(:conditions) { |b| sanitized_text b.conditions }
    actions
  end

  show do
    attributes_table do
      row(:kind) { |b| kind_of_badge b }
      row :name
      row :received_date
      row(:conditions) { |b| sanitized_text b.conditions }
    end
  end

  form partial: 'form'

  sidebar 'Управление наградой', only: :show do
    para link_to 'Обладатели', admin_badge_trophies_path(resource)
    h3 'Предпросмотр'
    image_tag resource.image.variant(:web), class: 'img-badge' if resource.image.attached?
  end
end
