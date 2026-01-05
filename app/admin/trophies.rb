# frozen_string_literal: true

ActiveAdmin.register Trophy do
  belongs_to :badge

  includes :athlete

  actions :all, except: :show

  permit_params :badge_id, :athlete_id, :date

  config.filters = false

  index download_links: false do
    selectable_column
    column :athlete
    column :date
    column :info
    column :updated_at
    actions
  end

  form do |f|
    f.semantic_errors(*f.object.errors.attribute_names)
    f.inputs do
      f.input :badge_id, as: :hidden
      f.input :athlete_id, label: 'ID участника в базе'
      li do
        f.label :date
        f.date_field(
          :date,
          value: f.object.date || resource.badge.received_date,
          max: 2.days.from_now,
        )
      end
    end
    f.actions
  end
end
