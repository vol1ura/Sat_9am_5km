# frozen_string_literal: true

class AddKuskovoOpenBadge < ActiveRecord::Migration[7.0]
  def change
    Badge.find_or_create_by!(id: 3) do |badge|
      badge.name = 'Кусково. Открытие'
      badge.conditions = 'Волонтёр или участник забега в субботу 10 декабря 2022 года. Бейджик посвящён первому забегу S95 в парке Кусково.'
      badge.picture_link = 'badges/kuskovo_open_2022.png'
      badge.received_date = '10.12.2022'
    end
  end
end
