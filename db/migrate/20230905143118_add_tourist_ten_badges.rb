# frozen_string_literal: true

class AddTouristTenBadges < ActiveRecord::Migration[7.0]
  def up
    badge = Badge.find_or_create_by!(id: 32) do |b|
      b.name = 'Волонтёр-турист 10'
      b.conditions = '<p>Волонтёрство в 10 различных локациях парковых забегов.</p>'
      b.picture_link = 'badges/tourist_volunteer_10.png'
    end
    badge.update!(info: { threshold: 10, type: 'volunteer' }, kind: :tourist)

    badge = Badge.find_or_create_by!(id: 33) do |b|
      b.name = 'Участник-турист 10'
      b.conditions = '<p>Финиш в 10 различных локациях парковых забегов.</p>'
      b.picture_link = 'badges/tourist_athlete_10.png'
    end
    badge.update!(info: { threshold: 10, type: 'athlete' }, kind: :tourist)
  end

  def down
    Badge.where(id: [32, 33]).destroy_all
  end
end
