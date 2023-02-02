# frozen_string_literal: true

class BadgesController < ApplicationController
  def index
    @funrun_badges = Badge.funrun_kind.order(received_date: :desc)
    @not_funrun_badges = Badge.not_funrun_kind.order(created_at: :desc)
  end

  def show
    @badge = Badge.find(params[:id])
    @trophies = @badge.trophies.includes(athlete: :club).order('date DESC', 'athletes.name').page(params[:page]).per(25)
  end
end
