# frozen_string_literal: true

class BadgesController < ApplicationController
  def index
    @badges = Badge.all
  end

  def show
    # @club = Badge.find(params[:id])
    head :not_found
  end
end
