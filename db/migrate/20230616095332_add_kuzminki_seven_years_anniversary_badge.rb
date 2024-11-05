# frozen_string_literal: true

class AddKuzminkiSevenYearsAnniversaryBadge < ActiveRecord::Migration[7.0]
  def up
    Badge.find_or_create_by!(id: 28) do |badge|
      badge.name = 'Седьмая годовщина субботних пробежек в Кузьминках'
      badge.conditions =
        'Волонтёр или участник забега в субботу 17 июня 2023 года. ' \
        'Значок посвящён семилетию парковых пробежек в Кузьминках.'
      badge.picture_link = 'badges/kuzminki_7_years.png'
      badge.received_date = '17.06.2023'
    end
  end

  def down
    Badge.find(28).destroy
  end
end
