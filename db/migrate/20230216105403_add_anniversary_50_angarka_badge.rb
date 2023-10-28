# frozen_string_literal: true

class AddAnniversary50AngarkaBadge < ActiveRecord::Migration[7.0]
  def change
    Badge.find_or_create_by!(id: 26) do |badge|
      badge.name = 'Ангарские пруды 50'
      badge.conditions = 'Все участники и волонтёры юбилейного 50-ого паркового забега на Ангарских прудах.'
      badge.picture_link = 'badges/angarka_50.png'
      badge.received_date = '18.02.2023'
    end
  end
end
