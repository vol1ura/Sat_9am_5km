# frozen_string_literal: true

ActiveAdmin.register Trophy do
  belongs_to :badge

  includes :badge, :athlete

  permit_params :badge_id, :athlete_id, :date

  config.filters = false

  form do |f|
    f.semantic_errors(*f.object.errors.attribute_names)
    f.inputs do
      f.input :badge_id, as: :hidden
      f.input :athlete_id, label: 'ID участника в базе'
      f.input :date, as: :datepicker, datepicker_options: { min_date: '-3M', max_date: '+2D' }
    end
    f.actions
  end
end
