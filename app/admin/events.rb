# frozen_string_literal: true

ActiveAdmin.register Event do
  menu priority: 2
  actions :all, except: :destroy

  permit_params do
    permitted = [:description]
    if params[:action] == 'create' && current_user.admin?
      permitted << :code_name
      permitted << :town
    end
    permitted << :active if current_user.admin?
    permitted << :place if current_user.admin?
    permitted
  end

  filter :active
  filter :code_name
  filter :town
  filter :place
end
