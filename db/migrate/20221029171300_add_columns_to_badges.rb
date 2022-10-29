class AddColumnsToBadges < ActiveRecord::Migration[7.0]
  def change
    add_column :badges, :kind, :integer, default: 0, null: false
    add_column :badges, :info, :jsonb, default: '{}', null: false
    add_column :trophies, :info, :jsonb, default: '{}', null: false

    add_index :badges, :info, using: :gin
    add_index :trophies, :info, using: :gin

    Badge.find_or_create_by!(id: 1) do |badge|
      badge.name = 'SPORT-MARAFON FEST 2022'
      badge.conditions = "Участие в фан-ране на фестивале Спорт-Марафон в качестве бегуна или волонтёра."
      badge.picture_link = 'badges/sm_fest.png'
      badge.received_date = '04.06.2022'
    end

    Badge.find_or_create_by!(id: 2) do |badge|
      badge.name = 'Забег Маяков'
      badge.conditions = "Для получения бейджика нужно быть волонтёром или совершить пробежку в Кузьминках. Важным условием получения является в наличие в экипировки элемента из коллекции \"Маяк\" GRI: майка, футболка, шорты, рукава или даже зимняя шапка с помпоном."
      badge.picture_link = 'badges/pharos_gri_2022.png'
      badge.received_date = '06.08.2022'
    end

    Badge.find_or_create_by!(id: 4) do |badge|
      badge.name = 'Фан-ран Московского Марафона'
      badge.conditions = 'Участник или волонтёр фан-рана в Кузьминках.'
      badge.picture_link = 'badges/mm_funrun_2022.png'
      badge.received_date = '17.09.2022'
    end

    Badge.find_or_create_by!(id: 6) do |badge|
      badge.name = 'IzMyLong - 2 года!'
      badge.conditions = "Волонтёр или участник забега в субботу 15 октября. Бейджик посвящён сообществу IzMyLong, которое  отмечает свой День рождения."
      badge.picture_link = 'badges/izmylong_2_years.png'
      badge.received_date = '15.10.2022'
    end

    badge = Badge.find_or_create_by!(id: 7) do |badge|
      badge.name = '25 забегов'
      badge.conditions = 'Совершить 25 забегов, учтённых в системе s95.'
      badge.picture_link = 'badges/25_runs.png'
    end
    badge.update!(info: { threshold: 25, type: 'athlete' }, kind: :participating)

    badge = Badge.find_or_create_by!(id: 8) do |badge|
      badge.name = '50 забегов'
      badge.conditions = 'Совершить 50 забегов, учтённых в системе s95.'
      badge.picture_link = 'badges/50_runs.png'
    end
    badge.update!(info: { threshold: 50, type: 'athlete' }, kind: :participating)

    badge = Badge.find_or_create_by!(id: 9) do |badge|
      badge.name = '100 забегов'
      badge.conditions = 'Совершить 100 забегов, учтённых в системе s95.'
      badge.picture_link = 'badges/100_runs.png'
    end
    badge.update!(info: { threshold: 100, type: 'athlete' }, kind: :participating)

    badge = Badge.find_or_create_by!(id: 10) do |badge|
      badge.name = '25 волонтёрств'
      badge.conditions = "25 волонтёрств на парковых забегах, учтённых в системе s95."
      badge.picture_link = 'badges/25_volunteering.png'
    end
    badge.update!(info: { threshold: 25, type: 'volunteer' }, kind: :participating)

    badge = Badge.find_or_create_by!(id: 11) do |badge|
      badge.name = '50 волонтёрств'
      badge.conditions = "50 волонтёрств на парковых забегах, учтённых в системе s95."
      badge.picture_link = 'badges/50_volunteering.png'
    end
    badge.update!(info: { threshold: 50, type: 'volunteer' }, kind: :participating)

    badge = Badge.find_or_create_by!(id: 12) do |badge|
      badge.name = '100 волонтёрств'
      badge.conditions = "100 волонтёрств на парковых забегах, учтённых в системе s95."
      badge.picture_link = 'badges/100_volunteering.png'
    end
    badge.update!(info: { threshold: 100, type: 'volunteer' }, kind: :participating)

    badge = Badge.find_or_create_by!(id: 13) do |badge|
      badge.name = 'Быстрее 16 минут'
      badge.conditions = "<p>Награда для мужчин, которые смогли пробежать 5 километров быстрее 16 минут. </p><p>Срок действия: 3 месяца с момента последнего забега быстрее 16 минут. Награда сгорает, если в течение 3 месяцев результат вновь не подтверждён.</p>"
      badge.picture_link = 'badges/breaking_16.png'
    end
    badge.update!(kind: :breaking, info: { min: 16, male: true })

    badge = Badge.find_or_create_by!(id: 14) do |badge|
      badge.name = 'Быстрее 18 минут'
      badge.conditions = "<p>Награда для мужчин, которые смогли пробежать 5 километров быстрее 18 минут. </p><p>Срок действия: 3 месяца с момента последнего забега быстрее 18 минут. Награда сгорает, если в течение 3 месяцев результат вновь не подтверждён.</p>"
      badge.picture_link = 'badges/breaking_18.png'
    end
    badge.update!(kind: :breaking, info: { min: 18, male: true })

    badge = Badge.find_or_create_by!(id: 15) do |badge|
      badge.name = 'Быстрее 20 минут'
      badge.conditions = "<p>Награда для мужчин, которые смогли пробежать 5 километров быстрее 20 минут. </p><p>Срок действия: 3 месяца с момента последнего забега быстрее 20 минут. Награда сгорает, если в течение 3 месяцев результат вновь не подтверждён.</p>"
      badge.picture_link = 'badges/breaking_20.png'
    end
    badge.update!(kind: :breaking, info: { min: 20, male: true })

    badge = Badge.find_or_create_by!(id: 16) do |badge|
      badge.name = 'Быстрее 19 минут'
      badge.conditions = "<p>Награда для девушек, которые смогли пробежать 5 километров быстрее 19 минут. </p><p>Срок действия: 3 месяца с момента последнего забега быстрее 19 минут. Награда сгорает, если в течение 3 месяцев результат вновь не подтверждён.</p>"
      badge.picture_link = 'badges/breaking_19.png'
    end
    badge.update!(kind: :breaking, info: { min: 19, male: false })

    badge = Badge.find_or_create_by!(id: 17) do |badge|
      badge.name = 'Быстрее 21 минуты'
      badge.conditions = "<p>Награда для девушек, которые смогли пробежать 5 километров быстрее 21 минуты. </p><p>Срок действия: 3 месяца с момента последнего забега быстрее 21 минуты. Награда сгорает, если в течение 3 месяцев результат вновь не подтверждён.</p>"
      badge.picture_link = 'badges/breaking_21.png'
    end
    badge.update!(kind: :breaking, info: { min: 21, male: false })

    badge = Badge.find_or_create_by!(id: 18) do |badge|
      badge.name = 'Быстрее 23 минут'
      badge.conditions = "<p>Награда для девушек, которые смогли пробежать 5 километров быстрее 23 минут. </p><p>Срок действия: 3 месяца с момента последнего забега быстрее 23 минут. Награда сгорает, если в течение 3 месяцев результат вновь не подтверждён.</p>"
      badge.picture_link = 'badges/breaking_23.png'
    end
    badge.update!(kind: :breaking, info: { min: 23, male: false })

    badge = badge = Badge.find_or_create_by!(id: 19) do |badge|
      badge.name = 'Волонтёр-турист 5'
      badge.conditions = "<p>Волонтёрство в 5 различных локациях парковых забегов.</p>"
      badge.picture_link = 'badges/tourist_volunteer_5.png'
    end
    badge.update!(info: { threshold: 5, type: 'volunteer' }, kind: :tourist)

    badge = Badge.find_or_create_by!(id: 20) do |badge|
      badge.name = 'Участник-турист 5'
      badge.conditions = "<p>Финиш в 5 различных локациях парковых забегов.</p>"
      badge.picture_link = 'badges/tourist_athlete_5.png'
    end
    badge.update!(info: { threshold: 5, type: 'athlete' }, kind: :tourist)

    badge = Badge.find_or_create_by!(id: 21) do |badge|
      badge.name = 'Королева паркового забега'
      badge.conditions = "<p>Награда для обладательницы лучшего женского результата за всё время проведения парковых забегов в конкретной локации.</p>"
      badge.picture_link = 'badges/record_woman.png'
    end
    badge.update!(info: { male: false }, kind: :king)

    badge = Badge.find_or_create_by!(id: 22) do |badge|
      badge.name = 'Король паркового забега'
      badge.conditions = "<p>Награда для обладателя лучшего мужского результата за всё время проведения парковых забегов в конкретной локации.</p>"
      badge.picture_link = 'badges/record_man.png'
    end
    badge.update!(info: { male: true }, kind: :king)
  end
end
