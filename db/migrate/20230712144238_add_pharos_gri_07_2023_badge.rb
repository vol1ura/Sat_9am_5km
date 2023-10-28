# frozen_string_literal: true

class AddPharosGri072023Badge < ActiveRecord::Migration[7.0]
  def up
    Badge.find_or_create_by!(id: 30) do |badge|
      badge.name = 'Забег Маяков'
      badge.conditions = 'Волонтёр или участник забега в Кузьминках, который проводится совместно с брендом GRI уже третий раз в Кузьминках и посвящён коллекции "Маяк".'
      badge.picture_link = 'badges/pharos_gri_072023.png'
      badge.received_date = '29.07.2023'
    end
  end

  def down
    Badge.find(30).destroy
  end
end
