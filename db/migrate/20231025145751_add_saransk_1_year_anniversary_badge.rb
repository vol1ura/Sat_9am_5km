# frozen_string_literal: true

class AddSaransk1YearAnniversaryBadge < ActiveRecord::Migration[7.0]
  def up
    Badge.find_or_create_by!(id: 36) do |badge|
      badge.name = '1 год 5 Вайгельбе'
      badge.conditions =
        'Волонтёр или участник забега в субботу 28 октября 2023 года. ' \
        'Значок посвящён годовщине парковых пробежек в Саранске.'
      badge.picture_link = 'badges/saransk_1_year.png'
      badge.received_date = '28.10.2023'
    end
  end

  def down
    Badge.find(36).destroy
  end
end
