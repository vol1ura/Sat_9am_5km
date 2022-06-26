# frozen_string_literal: true

class Athlete < ApplicationRecord
  FIVE_VERST_BORDER = 790000000

  belongs_to :club, optional: true
  belongs_to :user, optional: true

  has_many :results, dependent: :nullify
  has_many :activities, through: :results
  has_many :events, through: :activities

  validates :name, presence: true
  validates :parkrun_code, uniqueness: true, allow_nil: true
  validates :fiveverst_code, uniqueness: true, allow_nil: true

  def gender
    return if male.nil?

    male ? 'мужчина' : 'женщина'
  end
end
