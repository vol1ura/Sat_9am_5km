# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    return unless user
    can(:manage, :all) and return if user.admin?
    return if user.permissions.blank?

    @user = user
    can :read, ActiveAdmin::Page, name: 'Dashboard', namespace_name: 'admin'
    can %i[read update], User, id: @user.id

    special_permissions
    set_restrictions
  end

  private

  def special_permissions
    @user
      .permissions
      .group_by(&:subject_class)
      .transform_values { |permissions| permissions.group_by(&:action) }
      .each do |subject_class, actions|
        actions.each { |action, permissions| set_permission(action, subject_class, permissions) }
      end
  end

  def set_permission(action, subject_class, permissions)
    if subject_class == 'Athlete'
      can action.to_sym, Athlete
    else
      can action.to_sym, subject_class.constantize, permission_param(subject_class, permissions)
      can :new, subject_class.constantize if action.in?(%w[manage create])
    end
  end

  def permission_param(subject_class, permissions)
    param = { event_id: permissions.pluck(:event_id).compact.uniq }.compact_blank
    subject_class.in?(%w[Result Volunteer]) ? { activity: param }.compact_blank : param
  end

  def set_restrictions
    cannot :manage, Result, activity: { published: true, date: ..2.weeks.ago }
    cannot :manage, Volunteer, activity: { published: true, date: ..2.weeks.ago }
    cannot :update, Activity, published: true, date: ..2.weeks.ago
    cannot :destroy, Activity, published: true
    cannot :destroy, Athlete
    cannot :destroy, Club
  end
end
