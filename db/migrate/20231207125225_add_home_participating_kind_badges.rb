# frozen_string_literal: true

class AddHomeParticipatingKindBadges < ActiveRecord::Migration[7.0]
  def up
    create_badges!
    HomeBadgeAwardingJob.perform_now

    Badge
      .where(kind: %i[participating tourist])
      .where("info->>'type' = 'athlete'")
      .update_all(%{info = jsonb_set(info, '{type}', '"result"')})
  end

  def down
    badges_dataset = Badge.where(id: 39..44)

    Trophy.where(badge: badges_dataset).destroy_all
    badges_dataset.destroy_all

    Badge
      .where(kind: %i[participating tourist])
      .where("info->>'type' = 'result'")
      .update_all(%{info = jsonb_set(info, '{type}', '"athlete"')})
  end

  private

  def create_badges!
    Badge.find_or_create_by!(id: 39) do |badge|
      badge.name = 'Лучше дома 25 забегов'
      badge.conditions = 'Принять участие в 25 домашних забегах.'
      badge.picture_link = 'badges/25_home_runs.png'
      badge.info = { threshold: 25, type: 'result' }
      badge.kind = :home_participating
    end

    Badge.find_or_create_by!(id: 40) do |badge|
      badge.name = 'Лучше дома 50 забегов'
      badge.conditions = 'Принять участие в 50 домашних забегах.'
      badge.picture_link = 'badges/50_home_runs.png'
      badge.info = { threshold: 50, type: 'result' }
      badge.kind = :home_participating
    end

    Badge.find_or_create_by!(id: 41) do |badge|
      badge.name = 'Лучше дома 100 забегов'
      badge.conditions = 'Принять участие в 100 домашних забегах.'
      badge.picture_link = 'badges/100_home_runs.png'
      badge.info = { threshold: 100, type: 'result' }
      badge.kind = :home_participating
    end

    Badge.find_or_create_by!(id: 42) do |badge|
      badge.name = 'Лучше дома 25 волонтёрств'
      badge.conditions = '25 волонтёрств на домашнем забеге.'
      badge.picture_link = 'badges/25_home_volunteering.png'
      badge.info = { threshold: 25, type: 'volunteer' }
      badge.kind = :home_participating
    end

    Badge.find_or_create_by!(id: 43) do |badge|
      badge.name = 'Лучше дома 50 волонтёрств'
      badge.conditions = '50 волонтёрств на домашнем забеге.'
      badge.picture_link = 'badges/50_home_volunteering.png'
      badge.info = { threshold: 50, type: 'volunteer' }
      badge.kind = :home_participating
    end

    Badge.find_or_create_by!(id: 44) do |badge|
      badge.name = 'Лучше дома 100 волонтёрств'
      badge.conditions = '100 волонтёрств на домашнем забеге.'
      badge.picture_link = 'badges/100_home_volunteering.png'
      badge.info = { threshold: 100, type: 'volunteer' }
      badge.kind = :home_participating
    end
  end
end
