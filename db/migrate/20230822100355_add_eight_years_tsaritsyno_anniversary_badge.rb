class AddEightYearsTsaritsynoAnniversaryBadge < ActiveRecord::Migration[7.0]
  def up
    Badge.find_or_create_by!(id: 31) do |badge|
      badge.name = '∞≠lim'
      badge.conditions = 'Волонтёр или участник забега в Царицыно. Значок посвящён восьмилетию парковых пробежек в Царицыно.'
      badge.picture_link = 'badges/tsaritsyno_8_years.png'
      badge.received_date = '26.08.2023'
    end
  end

  def down
    Badge.find(31).destroy
  end
end
