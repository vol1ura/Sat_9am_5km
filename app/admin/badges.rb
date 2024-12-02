# frozen_string_literal: true

ActiveAdmin.register Badge do
  menu priority: 80
  actions :all, except: :destroy

  permit_params(
    :image,
    :received_date,
    { name_translations: I18n.available_locales },
    { conditions_translations: I18n.available_locales },
  )

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
      if badge.funrun_kind?
        row :received_date
        row(:country) { |b| t("country.#{b.country_code}") if b.country_code }
      end
      row(:conditions) { |b| sanitized_text b.conditions }
    end
  end

  form partial: 'form'

  before_save do |badge|
    if badge.funrun_kind?
      if params[:country_code].present? && Country.exists?(code: params[:country_code])
        badge.country_code = params[:country_code]
      elsif params.key? :country_code
        badge.info.delete('country_code')
      end
    end
  end

  sidebar 'Управление наградой', only: :show do
    para link_to 'Обладатели', admin_badge_trophies_path(resource)
    h3 'Предпросмотр'
    image_tag resource.image.variant(:web), class: 'img-badge' if resource.image.attached?
  end
end
