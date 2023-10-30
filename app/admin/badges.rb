# frozen_string_literal: true

ActiveAdmin.register Badge do
  actions :all, except: :destroy

  permit_params :name, :conditions, :received_date, :picture_link

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
      row :picture_link
      row(:conditions) { |b| sanitized_text b.conditions }
    end
  end

  form partial: 'form'

  sidebar 'Управление наградой', only: :show do
    para link_to 'Обладатели', admin_badge_trophies_path(resource)
    h3 'Предпросмотр'
    image_tag resource.picture_link, class: 'img-badge'
  end
end
