# frozen_string_literal: true

class AddKuskovoOneYearAnniversaryBadge < ActiveRecord::Migration[7.0]
  def up
    Badge.find_or_create_by!(id: 38) do |badge|
      badge.name = '#годбегаемвкусково'
      badge.conditions = 'Волонтёр или участник забега в субботу 9 декабря 2023 года на S95 Кусково. Значок посвящён годовщине парковых пробежек в парке Кусково.'
      badge.picture_link = 'badges/kuskovo_1_year.png'
      badge.received_date = '09.12.2023'
    end
  end

  def down
    Badge.find(38).destroy
  end
end
