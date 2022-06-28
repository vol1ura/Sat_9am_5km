# frozen_string_literal: true

ActiveAdmin.register Event do
  menu priority: 2
  actions :all, except: :destroy

  permit_params do
    permitted = %i[description active place name]
    if params[:action] == 'create'
      permitted << :code_name
      permitted << :town
    end
    permitted
  end

  filter :active
  filter :code_name
  filter :name
  filter :town
  filter :place

  index download_links: false do
    column :active
    column :code_name
    column :name
    column :town
    column :place
    column :created_at
    actions
  end
end
