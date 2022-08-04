# frozen_string_literal: true

ActiveAdmin.register User do
  actions :all, except: :destroy

  permit_params do
    permitted = %i[first_name last_name password password_confirmation]
    permitted << :role if current_user.admin?
  end

  filter :email
  filter :first_name
  filter :last_name

  index download_links: false do
    selectable_column
    column :email
    column :first_name
    column :last_name
    column :role
    column :created_at
    actions
  end

  show { render user }

  form do |f|
    f.inputs do
      f.input :email
      f.input :first_name
      f.input :last_name
      f.input :password
      f.input :password_confirmation
      f.input :role if current_user.admin?
    end
    f.actions
  end

  batch_action :change_roles, confirm: I18n.t('active_admin.users.confirm_change_roles'),
                              if: proc { can? :manage, User },
                              form: { role: [nil, *User::ROLE.keys] } do |ids, inputs|
    collection = batch_action_collection.where(id: ids)
    collection.update_all(role: inputs[:role]) # rubocop:disable Rails/SkipsModelValidations
    redirect_to collection_path, notice: I18n.t('active_admin.users.successful_roles_changed')
  end
end
