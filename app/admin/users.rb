# frozen_string_literal: true

ActiveAdmin.register User do
  actions :all, except: :destroy

  menu if: proc { current_user.admin? }

  permit_params do
    permitted = %i[first_name last_name password password_confirmation email]
    permitted.push(:role, :note) if current_user.admin?
    permitted
  end

  filter :email
  filter :telegram_user
  filter :first_name
  filter :last_name

  scope :all
  scope :admin
  scope(:supervisors) { |scope| scope.joins(:permissions).distinct }

  index download_links: false do
    selectable_column
    column(:telegram_user) { |user| telegram_link user }
    column :first_name
    column :last_name
    if current_user.admin?
      column(:phone) { |user| user.phone.present? }
      column :note
      column :role
    end
    column :created_at
    actions
  end

  show { render user }

  form do |f|
    f.inputs do
      f.input :email
      f.input :first_name
      f.input :last_name
      if current_user == f.object || f.object.new_record?
        f.input :password
        f.input :password_confirmation
      end
      if current_user.admin?
        f.input :role
        f.input :note
      end
    end
    f.actions
  end

  action_item :permissions, only: %i[show edit], if: proc { can? :manage, Permission } do
    link_to 'Полномочия', admin_user_permissions_path(resource)
  end

  batch_action :change_roles, confirm: I18n.t('active_admin.users.confirm_change_roles'),
                              if: proc { can? :manage, User },
                              form: { role: [nil, *User.roles.keys] } do |ids, inputs|
    collection = batch_action_collection.where(id: ids)
    collection.update_all(role: inputs[:role]) # rubocop:disable Rails/SkipsModelValidations
    redirect_to collection_path, notice: I18n.t('active_admin.users.successful_roles_changed')
  end
end
