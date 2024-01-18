class AddKuzminki100RunsBadge < ActiveRecord::Migration[7.1]
  def up
    Badge.find_or_create_by!(id: 46) do |badge|
      badge.name = '100-й забег S95 Кузьминки'
      badge.conditions = 'Награда вручается всем участникам и волонтёрам сотого забега S95 Кузьминки. Сто суббот поддерживаем друг друга. Бежим дальше!'
      badge.picture_link = 'badges/kuzminki_100_runs.png'
      badge.received_date = '20.01.2024'
    end
  end

  def down
    Badge.find(46).destroy
  end
end
