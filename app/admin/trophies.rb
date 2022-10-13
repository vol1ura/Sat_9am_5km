# frozen_string_literal: true

ActiveAdmin.register Trophy do
  belongs_to :badge

  includes :badge, :athlete

  permit_params :badge_id, :athlete_id, :date

  config.filters = false

  index download_links: false

  form do |f|
    f.semantic_errors(*f.object.errors.attribute_names)
    f.inputs do
      f.input :badge_id, as: :hidden
      f.input :athlete_id, label: 'ID участника в базе'
      f.input :date, input_html: { value: f.object.date || resource.badge.received_date },
                     datepicker_options: { min_date: '-3M', max_date: '+2D' },
                     as: :datepicker
    end
    f.actions
  end
end
