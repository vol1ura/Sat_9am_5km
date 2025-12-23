# frozen_string_literal: true

ActiveAdmin.register User do
  actions :all, except: %i[new create]

  menu if: proc { current_user.admin? }

  permit_params do
    permitted = %i[first_name last_name password password_confirmation email]
    permitted.push(:role, :note) if current_user.admin?
    permitted
  end

  filter :first_name
  filter :last_name
  filter :telegram_user
  filter :email

  scope :all
  scope :admin
  scope :super_admin, if: -> { current_user.super_admin? }
  scope(:supervisors) { |scope| scope.joins(:permissions).distinct }

  index download_links: false do
    selectable_column
    column :first_name
    column :last_name
    column(:telegram_user) { |user| telegram_link user }
    if current_user.admin?
      column(:phone) { |user| user.phone.present? }
      column :note
    end
    column :role if current_user.super_admin?
    column :created_at
    actions
  end

  show { render user }

  form do |f|
    f.inputs do
      f.input :first_name
      f.input :last_name
      if current_user == f.object || f.object.new_record?
        f.input :email
        f.input :password
        f.input :password_confirmation
      end
      f.input :role if current_user.super_admin?
      f.input :note if current_user.admin?
    end
    f.actions
  end

  sidebar 'Фото', only: %i[show edit], if: proc { resource.image.attached? } do
    image_tag resource.image.variant(:web), class: 'img-badge'
  end

  action_item :permissions, only: %i[show edit], if: proc { current_user.admin? } do
    link_to t('admin.permissions'), admin_user_permissions_path(resource)
  end

  batch_action(
    :change_roles,
    confirm: I18n.t('active_admin.users.confirm_change_roles'),
    if: proc { current_user.admin? },
    form: { role: [nil, 'admin'] },
  ) do |ids, inputs|
    batch_action_collection.where(id: ids).update_all role: inputs[:role]
    redirect_to collection_path, notice: I18n.t('active_admin.users.successful_roles_changed')
  end
end
