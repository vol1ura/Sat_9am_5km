# frozen_string_literal: true

class BadgesController < ApplicationController
  def index
    @badges = Badge.order(created_at: :desc)
  end
end
