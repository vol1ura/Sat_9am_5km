# frozen_string_literal: true

ActiveAdmin.register Activity do
  permit_params :date
  menu label: 'Забеги', priority: 2
  filter :date
end
