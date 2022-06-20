# frozen_string_literal: true

class Athlete < ApplicationRecord
  has_many :results, dependent: :destroy
  has_many :activities, through: :results
end
