# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)
    can :read, :all
    if user.uploader?
      can :manage, Result
      can :manage, Activity
      cannot :destroy, Activity, published: true
    end
    can :manage, :all if user.admin?
  end
end
