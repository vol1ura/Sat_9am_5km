# frozen_string_literal: true

module Navigation
  ACTIVE_RULES = {
    events: { controller: 'events' },
    results: { controller: 'activities' },
    ratings: { controller: %w[ratings clubs duels] },
    ratings_hub: { controller: %w[ratings clubs duels] },
    badges: { controller: 'badges' },
    duels: { controller: 'duels', action: %w[index show] },
    friends_protocol: { controller: 'duels', action: 'protocol' },
    profile: { controller: 'athletes', action: 'show', signed_in: true },
    about_us: { controller: 'pages', page: 'about' },
    rules: { controller: 'pages', page: 'rules' },
    team: { controller: 'pages', page: 'team' },
    donation: { controller: 'pages', page: 'donation' },
    joining: { controller: 'pages', page: 'joining' },
    contacts: { controller: 'pages', page: 'feedback' },
    articles: { controller: 'articles' },
  }.freeze

  CONTACTS_PAGE_ITEM = { key: :contacts, path: :page_path, params: { page: 'feedback' } }.freeze

  MOVEMENT_ITEMS = [
    CONTACTS_PAGE_ITEM,
    { key: :about_us, path: :page_path, params: { page: 'about' } },
    { key: :rules, path: :page_path, params: { page: 'rules' } },
    { key: :team, path: :page_path, params: { page: 'team' }, domains: [:ru] },
    { key: :donation, path: :page_path, params: { page: 'donation' } },
    { key: :joining, path: :page_path, params: { page: 'joining' } },
  ].freeze

  GITHUB_URL = 'https://github.com/vol1ura/Sat_9am_5km'

  LOCALE_OPTIONS = [
    [:en, 'English', '🇬🇧'],
    [:ru, 'Русский', '🇷🇺'],
    [:sr, 'Srpski', '🇷🇸'],
  ].freeze

  FOOTER_SECTIONS = [
    {
      heading_key: :sections,
      items: [
        { key: :events, path: :events_path },
        { key: :results, path: :activities_path },
        { key: :ratings, path: :ratings_path, params: { type: 'results' } },
        { key: :badges, path: :badges_path },
        { key: :articles, path: :articles_path },
      ],
    },
    {
      heading_key: :movement,
      items: MOVEMENT_ITEMS,
    },
  ].freeze

  BOTTOM_NAV_ITEMS = [
    { key: :events, path: :map_events_path, icon: 'map-location-dot' },
    { key: :results, path: :activities_path, icon: 'square-poll-horizontal' },
    { key: :ratings, path: :ratings_path, params: { type: 'results' }, icon: 'ranking-star' },
    { key: :more, action: :sheet, icon: 'ellipsis' },
  ].freeze

  DESKTOP_NAV_ITEMS = [
    { key: :events, path: :events_path },
    { key: :results, path: :activities_path },
    { key: :ratings, path: :ratings_path, params: { type: 'results' } },
    { key: :badges, path: :badges_path },
    { key: :movement, children: [*MOVEMENT_ITEMS, { key: :articles, path: :articles_path }] },
  ].freeze

  SHEET_SECTIONS = [
    {
      key: :sections,
      items: [
        { key: :badges, path: :badges_path },
        { key: :articles, path: :articles_path },
      ],
    },
    {
      key: :movement,
      items: MOVEMENT_ITEMS,
    },
  ].freeze
end
