# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    return unless user
    can(:manage, :all) and return if user.admin?

    can :read, ActiveAdmin::Page, name: 'Dashboard', namespace_name: 'admin'
    can :manage, User, id: user.id

    user.permissions.each do |permission|
      params = {}
      params[:id] = permission.subject_id if permission.subject_id
      if permission.subject_class == 'Activity'
        params[:event_id] = permission.event_id if permission.event_id
        can permission.action.to_sym, Activity, params
        cannot :destroy, Activity, published: true
      else
        can permission.action.to_sym, permission.subject_class.constantize, params
      end
    end
  end
end
