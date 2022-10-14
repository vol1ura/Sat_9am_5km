# frozen_string_literal: true

class BadgesController < ApplicationController
  def index
    @badges = Badge.order(created_at: :desc)
  end

  def show
    @badge = Badge.find(params[:id])
    @trophies = @badge.trophies.includes(athlete: :club).order('athletes.name').page(params[:page]).per(25)
  end
end
