# frozen_string_literal: true

class Event < ApplicationRecord
  has_many :activities, dependent: :destroy
  has_many :contacts, dependent: :destroy

  validates :name, :code_name, :town, :place, presence: true
  validates :code_name, uniqueness: true, format: { with: /\A[a-z_]+\z/ } # rubocop:disable Rails/UniqueValidationWithoutIndex

  default_scope { order(:visible_order, :name) }

  def self.authorized_for(user)
    return all if user.admin?

    where(id: user.permissions.where(subject_class: 'Result').select(:event_id))
  end
end
