class AddGolyanovoFirstRunBadge < ActiveRecord::Migration[7.0]
  def up
    Badge.find_or_create_by!(id: 35) do |badge|
      badge.name = 'Гольяново. Открытие'
      badge.conditions = 'Волонтёр или участник забега в субботу 30 сентября 2023 года. Награда посвящена первому забегу IzMyFive Гольяново.'
      badge.picture_link = 'badges/golyanovo_first_run.png'
      badge.received_date = '30.09.2023'
    end
  end

  def down
    Badge.find(35).destroy
  end
end
