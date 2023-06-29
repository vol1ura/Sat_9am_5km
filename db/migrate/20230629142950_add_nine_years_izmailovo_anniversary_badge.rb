class AddNineYearsIzmailovoAnniversaryBadge < ActiveRecord::Migration[7.0]
  def up
    Badge.find_or_create_by!(id: 29) do |badge|
      badge.name = '9 лет пробежкам в Измайлово'
      badge.conditions = 'Волонтёр или участник забега в субботу 1 июля 2023 года. Значок посвящён девятилетию парковых забегов в Измайловском парке.'
      badge.picture_link = 'badges/izmailovo_9_years.png'
      badge.received_date = '01.07.2023'
    end
  end

  def down
    Badge.find(29).destroy
  end
end
