# frozen_string_literal: true

class AddSmf2023Badge < ActiveRecord::Migration[7.0]
  def change
    Badge.find_or_create_by!(id: 27) do |badge|
      badge.name = 'Sport-Marafon fest 2023'
      badge.conditions = 'Участие в фан-ране на фестивале Спорт-Марафон в качестве бегуна или волонтёра.'
      badge.picture_link = 'badges/sm_fest_2023.png'
      badge.received_date = '03.06.2023'
    end
  end
end
