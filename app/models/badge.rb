# frozen_string_literal: true

class Badge < ApplicationRecord
  has_many :trophies, dependent: :destroy
  has_many :athletes, through: :trophies

  validates :kind, :name, presence: true
  validates :picture_link, presence: true, format: { with: /\A[^<>\s]+\z/ }

  enum kind: { funrun: 0, participating: 10, tourist: 20, breaking: 30, rage: 40, record: 100 }, _suffix: true

  def self.dataset_of(kind:, type:)
    public_send("#{kind}_kind").where("info->>'type' = ?", type).order(Arel.sql("info->'threshold'"))
  end
end
