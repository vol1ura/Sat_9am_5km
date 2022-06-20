# frozen_string_literal: true

class Result < ApplicationRecord
  belongs_to :activity
  belongs_to :athlete
end
