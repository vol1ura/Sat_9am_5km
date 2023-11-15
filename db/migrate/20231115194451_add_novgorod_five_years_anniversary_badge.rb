# frozen_string_literal: true
class AddNovgorodFiveYearsAnniversaryBadge < ActiveRecord::Migration[7.0]
  def up
    Badge.find_or_create_by!(id: 37) do |badge|
      badge.name = 'Новгородская беговая Республика'
      badge.conditions = 'Волонтёр или участник забега в субботу 18 ноября 2023 года runpark Великий Новгород. Значок посвящён годовщине парковых пробежек в Великом Новгороде.'
      badge.picture_link = 'badges/novgorod_5_years.png'
      badge.received_date = '18.11.2023'
    end
  end

  def down
    Badge.find(37).destroy
  end
end
