# frozen_string_literal: true

ActiveAdmin.register Result do
  belongs_to :activity, optional: true

  # actions :all, except: :destroy
  permit_params :total_time, :position, :role

  # menu priority: 2
  # filter :date
end
