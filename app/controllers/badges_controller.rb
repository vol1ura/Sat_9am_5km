# frozen_string_literal: true

class BadgesController < ApplicationController
  def index = redirect_to achievements_badges_path

  def achievements
    @badges = badges_dataset.not_funrun_kind.order(kind: :asc, created_at: :desc)
  end

  def funruns
    @badges = funrun_badges_scope.where(received_date: Badge.funrun_archive_cutoff..)
  end

  def archive
    @badges = funrun_badges_scope.where(received_date: ...Badge.funrun_archive_cutoff)
  end

  def show
    @badge = Badge.find(params.expect(:id))
    @trophies = @badge.trophies.includes(athlete: :club).order('date DESC', 'athletes.name').page(params[:page]).per(25)
  end

  private

  def badges_dataset = Badge.includes(image_attachment: :blob)

  def funrun_badges_scope
    badges_dataset
      .funrun_kind
      .where("info->>'country_code' IS NULL OR info->>'country_code' = ?", top_level_domain)
      .order(received_date: :desc)
  end
end
