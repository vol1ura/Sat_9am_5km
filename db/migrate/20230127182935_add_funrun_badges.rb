class AddFunrunBadges < ActiveRecord::Migration[7.0]
  def change
    Badge.find_or_create_by!(id: 23) do |badge|
      badge.name = 'Зимний Забег Маяков'
      badge.conditions = 'Волонтёр или участник забега в Кузьминках, который проводится совместно с брендом GRI и посвящён зимней коллекции "Маяк".'
      badge.picture_link = 'badges/pharos_gri_2023.png'
      badge.received_date = '18.02.2023'
    end
    Badge.find_or_create_by!(id: 24) do |badge|
      badge.name = 'Олимпийка - 5 лет!'
      badge.conditions = 'Волонтёр или участник забега в Олимпийской Деревне. Бейджик посвящён пятилетию парковых забегов в Олимпийской Деревне.'
      badge.picture_link = 'badges/5_peaks.png'
      badge.received_date = '04.03.2023'
    end
  end
end
