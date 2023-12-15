# frozen_string_literal: true

class AddBrestRun200Badge < ActiveRecord::Migration[7.0]
  def up
    Badge.find_or_create_by!(id: 45) do |badge|
      badge.name = '200-й забег #brestRun'
      badge.conditions = 'Волонтёр или участник забега в субботу 16 декабря 2023 года в Бресте. Значок посвящён 200-й парковой пробежке #brestRun'
      badge.picture_link = 'badges/brest_run_200.png'
      badge.received_date = '16.12.2023'
    end
  end

  def down
    Badge.find(45).destroy
  end
end
