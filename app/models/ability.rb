# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    return unless user
    can(:manage, :all) and return if user.admin?
    return if user.permissions.blank?

    @user = user
    base_permissions
    special_permissions
  end

  private

  def base_permissions
    can :read, ActiveAdmin::Page, name: 'Dashboard', namespace_name: 'admin'
    can %i[read update], User, id: @user.id
  end

  def special_permissions
    @user.permissions.each do |permission|
      can permission.action.to_sym, permission.subject_class.constantize, permission.params
    end
    cannot :destroy, Activity, published: true
    cannot :destroy, Athlete
  end
end
