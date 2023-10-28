# frozen_string_literal: true

class AddTenYearsAnniversaryBadge < ActiveRecord::Migration[7.0]
  def change
    Badge.find_or_create_by!(id: 5) do |badge|
      badge.name = '10 лет парковым забегам в России'
      badge.conditions = 'Волонтёр или участник забега в субботу 15 апреля 2023 года. Значок посвящён десятилетию парковых забегов в России.'
      badge.picture_link = 'badges/10_years_anniversary.png'
      badge.received_date = '15.04.2023'
    end
  end
end
