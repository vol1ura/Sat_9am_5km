class AddMm2023Badge < ActiveRecord::Migration[7.0]
  def up
    Badge.find_or_create_by!(id: 34) do |badge|
      badge.name = 'Фан-ран Московского Марафона 2023'
      badge.conditions = 'Награду получают все волонтёры и участники предмарафонского забега, вне зависимости от места проведения.'
      badge.picture_link = 'badges/mm_funrun_2023.png'
      badge.received_date = '16.09.2023'
    end
  end

  def down
    Badge.find(34).destroy
  end
end
