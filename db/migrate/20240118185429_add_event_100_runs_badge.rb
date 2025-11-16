# frozen_string_literal: true

class AddEvent100RunsBadge < ActiveRecord::Migration[7.1]
  def up
    Badge.find_or_create_by!(id: 46) do |badge|
      badge.name = '100-й забег в системе S95'
      badge.conditions =
        'Награда вручается всем участникам и волонтёрам локации, которая зафиксировала сто забегов на платформе S95. ' \
        'Сто суббот поддерживаем друг друга. Бежим дальше!'
      badge.picture_link = 'badges/event_100_runs.png'
      badge.kind = :jubilee_participating
      badge.info = { threshold: 100 }
    end
  end

  def down
    Badge.find(46).destroy
  end
end
