# frozen_string_literal: true

user = User.create!(
  telegram_id: ENV['DEV_TELEGRAM_ID'],
  role: 0,
  first_name: 'John',
  last_name: 'Doe',
)

russia = Country.create!(code: 'ru')

kuzminki = Event.create!(
  name: 'Кузьминки',
  code_name: 'kuzminki',
  town: 'Москва',
  place: 'Кузьминки',
  place_description: 'парк Кузьминки',
  description: 'Каждую субботу сбор в 8:45 возле сцены.',
  country: russia,
)
Event.create!(
  name: 'Олимпийская деревня',
  code_name: 'olimpiyskaya_derevnya',
  town: 'Москва',
  place: 'Олимпийская деревня',
  place_description: 'парк Олимпийская Деревня',
  description: 'Каждую субботу сбор в 8:45 где-то в парке.',
  country: russia,
)

club = Club.create!(
  name: Faker::Team.name,
  slug: Faker::Alphanumeric.unique.alphanumeric(number: 10).downcase,
  country: russia,
)

Athlete.create!(
  user: user,
  club: club,
  name: user.full_name,
  gender: 'male',
  event: kuzminki,
  fiveverst_code: 790_000_000 + Faker::Number.number(digits: 6),
)

50.times do
  Athlete.create!(
    name: Faker::Name.name,
    gender: Faker::Gender.binary_type.downcase,
    event: Event.order('RANDOM()').first,
    parkrun_code: Faker::Number.number(digits: 6),
  )
end

default_badge_image = Rails.root.join('spec/fixtures/files/default.png')

# rubocop:disable Layout/LineLength
[
  { id: 1, name: { ru: 'SPORT-MARAFON FEST 2022' }, conditions: { ru: 'Участие в фан-ране на фестивале Спорт-Марафон в качестве бегуна или волонтёра.' }, kind: :funrun, info: {}, received_date: Date.new(2022, 6, 4), image: 'badges/sm_fest.png' },
  { id: 2, name: { ru: 'Забег Маяков' }, conditions: { ru: 'Для получения бейджика нужно быть волонтёром или совершить пробежку в Кузьминках. Важным условием получения является в наличие в экипировки элемента из коллекции "Маяк" GRI: майка, футболка, шорты, рукава или даже зимняя шапка с помпоном.' }, kind: :funrun, info: {}, received_date: Date.new(2022, 8, 6), image: 'badges/pharos_gri_2022.png' },
  { id: 3, name: { ru: 'Кусково. Открытие' }, conditions: { ru: 'Волонтёр или участник забега в субботу 10 декабря 2022 года. Бейджик посвящён первому забегу S95 в парке Кусково.' }, kind: :funrun, info: {}, received_date: Date.new(2022, 12, 10), image: 'badges/kuskovo_open_2022.png' },
  { id: 4, name: { ru: 'Фан-ран Московского Марафона' }, conditions: { ru: 'Участник или волонтёр фан-рана в Кузьминках.' }, kind: :funrun, info: {}, received_date: Date.new(2022, 9, 17), image: 'badges/mm_funrun_2022.png' },
  { id: 5, name: { ru: '10 лет парковым забегам в России' }, conditions: { ru: 'Волонтёр или участник забега в субботу 15 апреля 2023 года. Значок посвящён десятилетию парковых забегов в России.' }, kind: :funrun, info: {}, received_date: Date.new(2023, 4, 15), image: 'badges/10_years_anniversary.png' },
  { id: 6, name: { ru: 'IzMyLong - 2 года!' }, conditions: { ru: 'Волонтёр или участник забега в субботу 15 октября. Бейджик посвящён сообществу IzMyLong, которое отмечает свой День рождения.' }, kind: :funrun, info: {}, received_date: Date.new(2022, 10, 15), image: 'badges/izmylong_2_years.png' },
  { id: 7, name: { ru: '25 забегов' }, conditions: { ru: 'Совершить 25 забегов, учтённых в системе s95.' }, kind: :participating, info: { threshold: 25, type: 'result' }, image: 'badges/25_runs.png' },
  { id: 8, name: { ru: '50 забегов' }, conditions: { ru: 'Совершить 50 забегов, учтённых в системе s95.' }, kind: :participating, info: { threshold: 50, type: 'result' }, image: 'badges/50_runs.png' },
  { id: 9, name: { ru: '100 забегов' }, conditions: { ru: 'Совершить 100 забегов, учтённых в системе s95.' }, kind: :participating, info: { threshold: 100, type: 'result' }, image: 'badges/100_runs.png' },
  { id: 10, name: { ru: '25 волонтёрств' }, conditions: { ru: '25 волонтёрств на парковых забегах, учтённых в системе s95.' }, kind: :participating, info: { threshold: 25, type: 'volunteer' }, image: 'badges/25_volunteering.png' },
  { id: 11, name: { ru: '50 волонтёрств' }, conditions: { ru: '50 волонтёрств на парковых забегах, учтённых в системе s95.' }, kind: :participating, info: { threshold: 50, type: 'volunteer' }, image: 'badges/50_volunteering.png' },
  { id: 12, name: { ru: '100 волонтёрств' }, conditions: { ru: '100 волонтёрств на парковых забегах, учтённых в системе s95.' }, kind: :participating, info: { threshold: 100, type: 'volunteer' }, image: 'badges/100_volunteering.png' },
  { id: 13, name: { ru: 'Быстрее 16 минут' }, conditions: { ru: '<p>Награда для мужчин, которые смогли пробежать 5 километров быстрее 16 минут.</p><p>Срок действия: 3 месяца с момента последнего забега быстрее 16 минут. Награда сгорает, если в течение 3 месяцев результат вновь не подтверждён.</p>' }, kind: :breaking, info: { sec: 960, gender: 'male' }, image: 'badges/breaking_16.png' },
  { id: 14, name: { ru: 'Быстрее 18 минут' }, conditions: { ru: '<p>Награда для мужчин, которые смогли пробежать 5 километров быстрее 18 минут.</p><p>Срок действия: 3 месяца с момента последнего забега быстрее 18 минут. Награда сгорает, если в течение 3 месяцев результат вновь не подтверждён.</p>' }, kind: :breaking, info: { sec: 1080, gender: 'male' }, image: 'badges/breaking_18.png' },
  { id: 15, name: { ru: 'Быстрее 20 минут' }, conditions: { ru: '<p>Награда для мужчин, которые смогли пробежать 5 километров быстрее 20 минут.</p><p>Срок действия: 3 месяца с момента последнего забега быстрее 20 минут. Награда сгорает, если в течение 3 месяцев результат вновь не подтверждён.</p>' }, kind: :breaking, info: { sec: 1200, gender: 'male' }, image: 'badges/breaking_20.png' },
  { id: 16, name: { ru: 'Быстрее 19 минут' }, conditions: { ru: '<p>Награда для девушек, которые смогли пробежать 5 километров быстрее 19 минут.</p><p>Срок действия: 3 месяца с момента последнего забега быстрее 19 минут. Награда сгорает, если в течение 3 месяцев результат вновь не подтверждён.</p>' }, kind: :breaking, info: { sec: 1140, gender: 'female' }, image: 'badges/breaking_19.png' },
  { id: 17, name: { ru: 'Быстрее 21 минуты' }, conditions: { ru: '<p>Награда для девушек, которые смогли пробежать 5 километров быстрее 21 минуты.</p><p>Срок действия: 3 месяца с момента последнего забега быстрее 21 минуты. Награда сгорает, если в течение 3 месяцев результат вновь не подтверждён.</p>' }, kind: :breaking, info: { sec: 1260, gender: 'female' }, image: 'badges/breaking_21.png' },
  { id: 18, name: { ru: 'Быстрее 23 минут' }, conditions: { ru: '<p>Награда для девушек, которые смогли пробежать 5 километров быстрее 23 минут.</p><p>Срок действия: 3 месяца с момента последнего забега быстрее 23 минут. Награда сгорает, если в течение 3 месяцев результат вновь не подтверждён.</p>' }, kind: :breaking, info: { sec: 1380, gender: 'female' }, image: 'badges/breaking_23.png' },
  { id: 19, name: { ru: 'Волонтёр-турист 5' }, conditions: { ru: '<p>Волонтёрство в 5 различных локациях парковых забегов.</p>' }, kind: :tourist, info: { threshold: 5, type: 'volunteer' }, image: 'badges/tourist_volunteer_5.png' },
  { id: 20, name: { ru: 'Участник-турист 5' }, conditions: { ru: '<p>Финиш в 5 различных локациях парковых забегов.</p>' }, kind: :tourist, info: { threshold: 5, type: 'result' }, image: 'badges/tourist_athlete_5.png' },
  { id: 21, name: { ru: 'Королева паркового забега' }, conditions: { ru: '<p>Награда для обладательницы лучшего женского результата за всё время проведения парковых забегов в конкретной локации.</p>' }, kind: :record, info: { gender: 'female' }, image: 'badges/record_woman.png' },
  { id: 22, name: { ru: 'Король паркового забега' }, conditions: { ru: '<p>Награда для обладателя лучшего мужского результата за всё время проведения парковых забегов в конкретной локации.</p>' }, kind: :record, info: { gender: 'male' }, image: 'badges/record_man.png' },
  { id: 23, name: { ru: 'Зимний Забег Маяков' }, conditions: { ru: 'Волонтёр или участник забега в Кузьминках, который проводится совместно с брендом GRI и посвящён зимней коллекции "Маяк".' }, kind: :funrun, info: {}, received_date: Date.new(2023, 2, 18), image: 'badges/pharos_gri_2023.png' },
  { id: 24, name: { ru: 'Олимпийка - 5 лет!' }, conditions: { ru: 'Волонтёр или участник забега в Олимпийской Деревне. Бейджик посвящён пятилетию парковых забегов в Олимпийской Деревне.' }, kind: :funrun, info: {}, received_date: Date.new(2023, 3, 4), image: 'badges/5_peaks.png' },
  { id: 25, name: { ru: 'Раж' }, conditions: { ru: 'Награда присуждается за непрерывную серию из трёх результатов участника, каждый их которых лучше предыдущего. Бейдж относится к типу "скоростных", а поэтому временный и держится на странице участника столько, сколько длится прогресс его результатов. Отсюда и происходит название: "войти в раж". Как только участник показывает результат хуже своего предыдущего, бейдж пропадает и серия из трёх пробежек начинается заново.' }, kind: :rage, info: {}, image: 'badges/rage.png' },
  { id: 26, name: { ru: 'Ангарские пруды 50' }, conditions: { ru: 'Все участники и волонтёры юбилейного 50-ого паркового забега на Ангарских прудах.' }, kind: :funrun, info: {}, received_date: Date.new(2023, 2, 18), image: 'badges/angarka_50.png' },
  { id: 27, name: { ru: 'Sport-Marafon fest 2023' }, conditions: { ru: 'Участие в фан-ране на фестивале Спорт-Марафон в качестве бегуна или волонтёра.' }, kind: :funrun, info: {}, received_date: Date.new(2023, 6, 3), image: 'badges/sm_fest_2023.png' },
  { id: 28, name: { ru: 'Седьмая годовщина субботних пробежек в Кузьминках' }, conditions: { ru: 'Волонтёр или участник забега в субботу 17 июня 2023 года. Значок посвящён семилетию парковых пробежек в Кузьминках.' }, kind: :funrun, info: {}, received_date: Date.new(2023, 6, 17), image: 'badges/kuzminki_7_years.png' },
  { id: 29, name: { ru: '9 лет пробежкам в Измайлово' }, conditions: { ru: 'Волонтёр или участник забега в субботу 1 июля 2023 года. Значок посвящён девятилетию парковых забегов в Измайловском парке.' }, kind: :funrun, info: {}, received_date: Date.new(2023, 7, 1), image: 'badges/izmailovo_9_years.png' },
  { id: 30, name: { ru: 'Забег Маяков' }, conditions: { ru: 'Волонтёр или участник забега в Кузьминках, который проводится совместно с брендом GRI уже третий раз в Кузьминках и посвящён коллекции "Маяк".' }, kind: :funrun, info: {}, received_date: Date.new(2023, 7, 29), image: 'badges/pharos_gri_072023.png' },
  { id: 31, name: { ru: '∞≠lim' }, conditions: { ru: 'Волонтёр или участник забега в Царицыно. Значок посвящён восьмилетию парковых пробежек в Царицыно.' }, kind: :funrun, info: {}, received_date: Date.new(2023, 8, 26), image: 'badges/tsaritsyno_8_years.png' },
  { id: 32, name: { ru: 'Волонтёр-турист 10' }, conditions: { ru: '<p>Волонтёрство в 10 различных локациях парковых забегов.</p>' }, kind: :tourist, info: { threshold: 10, type: 'volunteer' }, image: 'badges/tourist_volunteer_10.png' },
  { id: 33, name: { ru: 'Участник-турист 10' }, conditions: { ru: '<p>Финиш в 10 различных локациях парковых забегов.</p>' }, kind: :tourist, info: { threshold: 10, type: 'result' }, image: 'badges/tourist_athlete_10.png' },
  { id: 34, name: { ru: 'Фан-ран Московского Марафона 2023' }, conditions: { ru: 'Награду получают все волонтёры и участники предмарафонского забега, вне зависимости от места проведения.' }, kind: :funrun, info: {}, received_date: Date.new(2023, 9, 16), image: 'badges/mm_funrun_2023.png' },
  { id: 35, name: { ru: 'Гольяново. Открытие' }, conditions: { ru: 'Волонтёр или участник забега в субботу 30 сентября 2023 года. Награда посвящена первому забегу IzMyFive Гольяново.' }, kind: :funrun, info: {}, received_date: Date.new(2023, 9, 30), image: 'badges/golyanovo_first_run.png' },
  { id: 36, name: { ru: '1 год 5 Вайгельбе' }, conditions: { ru: 'Волонтёр или участник забега в субботу 28 октября 2023 года. Значок посвящён годовщине парковых пробежек в Саранске.' }, kind: :funrun, info: {}, received_date: Date.new(2023, 10, 28), image: 'badges/saransk_1_year.png' },
  { id: 37, name: { ru: 'Новгородская беговая Республика' }, conditions: { ru: 'Волонтёр или участник забега в субботу 18 ноября 2023 года runpark Великий Новгород. Значок посвящён годовщине парковых пробежек в Великом Новгороде.' }, kind: :funrun, info: {}, received_date: Date.new(2023, 11, 18), image: 'badges/novgorod_5_years.png' },
  { id: 38, name: { ru: '#годбегаемвкусково' }, conditions: { ru: 'Волонтёр или участник забега в субботу 9 декабря 2023 года на S95 Кусково. Значок посвящён годовщине парковых пробежек в парке Кусково.' }, kind: :funrun, info: {}, received_date: Date.new(2023, 12, 9), image: 'badges/kuskovo_1_year.png' },
  { id: 39, name: { ru: 'Лучше дома 25 забегов' }, conditions: { ru: 'Принять участие в 25 домашних забегах.' }, kind: :home_participating, info: { threshold: 25, type: 'result' }, image: 'badges/25_home_runs.png' },
  { id: 40, name: { ru: 'Лучше дома 50 забегов' }, conditions: { ru: 'Принять участие в 50 домашних забегах.' }, kind: :home_participating, info: { threshold: 50, type: 'result' }, image: 'badges/50_home_runs.png' },
  { id: 41, name: { ru: 'Лучше дома 100 забегов' }, conditions: { ru: 'Принять участие в 100 домашних забегах.' }, kind: :home_participating, info: { threshold: 100, type: 'result' }, image: 'badges/100_home_runs.png' },
  { id: 42, name: { ru: 'Лучше дома 25 волонтёрств' }, conditions: { ru: '25 волонтёрств на домашнем забеге.' }, kind: :home_participating, info: { threshold: 25, type: 'volunteer' }, image: 'badges/25_home_volunteering.png' },
  { id: 43, name: { ru: 'Лучше дома 50 волонтёрств' }, conditions: { ru: '50 волонтёрств на домашнем забеге.' }, kind: :home_participating, info: { threshold: 50, type: 'volunteer' }, image: 'badges/50_home_volunteering.png' },
  { id: 44, name: { ru: 'Лучше дома 100 волонтёрств' }, conditions: { ru: '100 волонтёрств на домашнем забеге.' }, kind: :home_participating, info: { threshold: 100, type: 'volunteer' }, image: 'badges/100_home_volunteering.png' },
  { id: 45, name: { ru: '200-й забег #brestRun' }, conditions: { ru: 'Волонтёр или участник забега в субботу 16 декабря 2023 года в Бресте. Значок посвящён 200-й парковой пробежке #brestRun' }, kind: :funrun, info: {}, received_date: Date.new(2023, 12, 16), image: 'badges/brest_run_200.png' },
  { id: 46, name: { ru: '100-й забег в системе S95' }, conditions: { ru: 'Награда вручается всем участникам и волонтёрам локации, которая зафиксировала сто забегов на платформе S95. Сто суббот поддерживаем друг друга. Бежим дальше!' }, kind: :jubilee_participating, info: { threshold: 100 }, image: 'badges/event_100_runs.png' },
].each do |attrs|
  badge = Badge.find_or_initialize_by(id: attrs[:id])
  badge.assign_attributes(
    kind: attrs[:kind],
    info: attrs[:info],
    received_date: attrs[:received_date],
    name_translations: attrs[:name],
    conditions_translations: attrs[:conditions],
  )

  unless badge.image.attached?
    image_path = Rails.root.join('app/assets/images', attrs[:image])
    image_path = default_badge_image unless image_path.exist?

    badge.image.attach(io: File.open(image_path), filename: File.basename(image_path))
  end

  badge.save!
end
# rubocop:enable Layout/LineLength
