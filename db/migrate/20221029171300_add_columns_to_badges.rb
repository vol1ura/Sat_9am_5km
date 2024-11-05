# frozen_string_literal: true

class AddColumnsToBadges < ActiveRecord::Migration[7.0]
  def change
    change_table :badges, bulk: true do |t|
      t.column :kind, :integer, default: 0, null: false
      t.column :info, :jsonb, default: '{}', null: false
      t.index :info, using: :gin
    end

    change_table :trophies, bulk: true do |t|
      t.column :info, :jsonb, default: '{}', null: false
      t.index :info, using: :gin
    end

    Badge.find_or_create_by!(id: 1) do |b|
      b.name = 'SPORT-MARAFON FEST 2022'
      b.conditions = 'Участие в фан-ране на фестивале Спорт-Марафон в качестве бегуна или волонтёра.'
      b.picture_link = 'badges/sm_fest.png'
      b.received_date = '04.06.2022'
    end

    Badge.find_or_create_by!(id: 2) do |b|
      b.name = 'Забег Маяков'
      b.conditions =
        'Для получения бейджика нужно быть волонтёром или совершить пробежку в Кузьминках. ' \
        'Важным условием получения является в наличие в экипировки элемента из коллекции ' \
        '"Маяк" GRI: майка, футболка, шорты, рукава или даже зимняя шапка с помпоном.'
      b.picture_link = 'badges/pharos_gri_2022.png'
      b.received_date = '06.08.2022'
    end

    Badge.find_or_create_by!(id: 4) do |b|
      b.name = 'Фан-ран Московского Марафона'
      b.conditions = 'Участник или волонтёр фан-рана в Кузьминках.'
      b.picture_link = 'badges/mm_funrun_2022.png'
      b.received_date = '17.09.2022'
    end

    Badge.find_or_create_by!(id: 6) do |b|
      b.name = 'IzMyLong - 2 года!'
      b.conditions =
        'Волонтёр или участник забега в субботу 15 октября. Бейджик посвящён сообществу IzMyLong, ' \
        'которое отмечает свой День рождения.'
      b.picture_link = 'badges/izmylong_2_years.png'
      b.received_date = '15.10.2022'
    end

    badge = Badge.find_or_create_by!(id: 7) do |b|
      b.name = '25 забегов'
      b.conditions = 'Совершить 25 забегов, учтённых в системе s95.'
      b.picture_link = 'badges/25_runs.png'
    end
    badge.update!(info: { threshold: 25, type: 'athlete' }, kind: :participating)

    badge = Badge.find_or_create_by!(id: 8) do |b|
      b.name = '50 забегов'
      b.conditions = 'Совершить 50 забегов, учтённых в системе s95.'
      b.picture_link = 'badges/50_runs.png'
    end
    badge.update!(info: { threshold: 50, type: 'athlete' }, kind: :participating)

    badge = Badge.find_or_create_by!(id: 9) do |b|
      b.name = '100 забегов'
      b.conditions = 'Совершить 100 забегов, учтённых в системе s95.'
      b.picture_link = 'badges/100_runs.png'
    end
    badge.update!(info: { threshold: 100, type: 'athlete' }, kind: :participating)

    badge = Badge.find_or_create_by!(id: 10) do |b|
      b.name = '25 волонтёрств'
      b.conditions = '25 волонтёрств на парковых забегах, учтённых в системе s95.'
      b.picture_link = 'badges/25_volunteering.png'
    end
    badge.update!(info: { threshold: 25, type: 'volunteer' }, kind: :participating)

    badge = Badge.find_or_create_by!(id: 11) do |b|
      b.name = '50 волонтёрств'
      b.conditions = '50 волонтёрств на парковых забегах, учтённых в системе s95.'
      b.picture_link = 'badges/50_volunteering.png'
    end
    badge.update!(info: { threshold: 50, type: 'volunteer' }, kind: :participating)

    badge = Badge.find_or_create_by!(id: 12) do |b|
      b.name = '100 волонтёрств'
      b.conditions = '100 волонтёрств на парковых забегах, учтённых в системе s95.'
      b.picture_link = 'badges/100_volunteering.png'
    end
    badge.update!(info: { threshold: 100, type: 'volunteer' }, kind: :participating)

    badge = Badge.find_or_create_by!(id: 13) do |b|
      b.name = 'Быстрее 16 минут'
      b.conditions =
        '<p>Награда для мужчин, которые смогли пробежать 5 километров быстрее 16 минут.</p>' \
        '<p>Срок действия: 3 месяца с момента последнего забега быстрее 16 минут. ' \
        'Награда сгорает, если в течение 3 месяцев результат вновь не подтверждён.</p>'
      b.picture_link = 'badges/breaking_16.png'
    end
    badge.update!(kind: :breaking, info: { min: 16, male: true })

    badge = Badge.find_or_create_by!(id: 14) do |b|
      b.name = 'Быстрее 18 минут'
      b.conditions =
        '<p>Награда для мужчин, которые смогли пробежать 5 километров быстрее 18 минут.</p>' \
        '<p>Срок действия: 3 месяца с момента последнего забега быстрее 18 минут. ' \
        'Награда сгорает, если в течение 3 месяцев результат вновь не подтверждён.</p>'
      b.picture_link = 'badges/breaking_18.png'
    end
    badge.update!(kind: :breaking, info: { min: 18, male: true })

    badge = Badge.find_or_create_by!(id: 15) do |b|
      b.name = 'Быстрее 20 минут'
      b.conditions =
        '<p>Награда для мужчин, которые смогли пробежать 5 километров быстрее 20 минут.</p>' \
        '<p>Срок действия: 3 месяца с момента последнего забега быстрее 20 минут. ' \
        'Награда сгорает, если в течение 3 месяцев результат вновь не подтверждён.</p>'
      b.picture_link = 'badges/breaking_20.png'
    end
    badge.update!(kind: :breaking, info: { min: 20, male: true })

    badge = Badge.find_or_create_by!(id: 16) do |b|
      b.name = 'Быстрее 19 минут'
      b.conditions =
        '<p>Награда для девушек, которые смогли пробежать 5 километров быстрее 19 минут.</p>' \
        '<p>Срок действия: 3 месяца с момента последнего забега быстрее 19 минут. ' \
        'Награда сгорает, если в течение 3 месяцев результат вновь не подтверждён.</p>'
      b.picture_link = 'badges/breaking_19.png'
    end
    badge.update!(kind: :breaking, info: { min: 19, male: false })

    badge = Badge.find_or_create_by!(id: 17) do |b|
      b.name = 'Быстрее 21 минуты'
      b.conditions =
        '<p>Награда для девушек, которые смогли пробежать 5 километров быстрее 21 минуты.</p>' \
        '<p>Срок действия: 3 месяца с момента последнего забега быстрее 21 минуты. Награда сгорает, ' \
        'если в течение 3 месяцев результат вновь не подтверждён.</p>'
      b.picture_link = 'badges/breaking_21.png'
    end
    badge.update!(kind: :breaking, info: { min: 21, male: false })

    badge = Badge.find_or_create_by!(id: 18) do |b|
      b.name = 'Быстрее 23 минут'
      b.conditions =
        '<p>Награда для девушек, которые смогли пробежать 5 километров быстрее 23 минут.</p>' \
        '<p>Срок действия: 3 месяца с момента последнего забега быстрее 23 минут. ' \
        'Награда сгорает, если в течение 3 месяцев результат вновь не подтверждён.</p>'
      b.picture_link = 'badges/breaking_23.png'
    end
    badge.update!(kind: :breaking, info: { min: 23, male: false })

    badge = Badge.find_or_create_by!(id: 19) do |b|
      b.name = 'Волонтёр-турист 5'
      b.conditions = '<p>Волонтёрство в 5 различных локациях парковых забегов.</p>'
      b.picture_link = 'badges/tourist_volunteer_5.png'
    end
    badge.update!(info: { threshold: 5, type: 'volunteer' }, kind: :tourist)

    badge = Badge.find_or_create_by!(id: 20) do |b|
      b.name = 'Участник-турист 5'
      b.conditions = '<p>Финиш в 5 различных локациях парковых забегов.</p>'
      b.picture_link = 'badges/tourist_athlete_5.png'
    end
    badge.update!(info: { threshold: 5, type: 'athlete' }, kind: :tourist)

    badge = Badge.find_or_create_by!(id: 21) do |b|
      b.name = 'Королева паркового забега'
      b.conditions =
        '<p>Награда для обладательницы лучшего женского результата за всё время проведения парковых забегов ' \
        'в конкретной локации.</p>'
      b.picture_link = 'badges/record_woman.png'
    end
    badge.update!(info: { male: false }, kind: :record)

    badge = Badge.find_or_create_by!(id: 22) do |b|
      b.name = 'Король паркового забега'
      b.conditions =
        '<p>Награда для обладателя лучшего мужского результата за всё время проведения парковых забегов ' \
        'в конкретной локации.</p>'
      b.picture_link = 'badges/record_man.png'
    end
    badge.update!(info: { male: true }, kind: :record)
  end
end
