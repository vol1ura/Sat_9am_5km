Country.find_each do |country|
  SitemapGenerator::Sitemap.default_host = "https://#{country.host}"
  SitemapGenerator::Sitemap.sitemaps_path = "sitemaps/#{country.code}"
  SitemapGenerator::Sitemap.compress = false

  SitemapGenerator::Sitemap.create do
    # Put links creation logic here.
    #
    # The root path '/' and sitemap index file are added automatically for you.
    # Links are added to the Sitemap in the order they are specified.
    #
    # Defaults: priority: 0.5, changefreq: 'weekly', lastmod: Time.now, host: default_host
    #
    # Add '/pages'
    Dir.glob('app/views/pages/*.html.erb').each do |file|
      page = File.basename(file, '.html.erb')
      add page_path(page) if PagesController::ALLOWED_PAGES.include?(page)
    end
    # Add '/articles'
    add articles_path
    Dir.glob('app/views/articles/*.html.erb').each do |file|
      page = File.basename(file, '.html.erb')
      add article_path(page) if ArticlesController::ALLOWED_PAGES.include?(page)
    end
    # Add '/ratings' endpoints
    add results_ratings_path, priority: 0.75
    add ratings_path(type: 'results'), priority: 0.9
    add ratings_path(type: 'volunteers'), priority: 0.9
    #
    # Add all events:
    add events_path
    saturday_date = Date.current.saturday? ? Date.current : Date.tomorrow.prev_week(:saturday)
    country.events.find_each do |event|
      add event_path(event.code_name), lastmod: saturday_date, priority: 0.99
      add volunteering_event_path(event.code_name)
    end
    #
    # Add activities
    add activities_path, priority: 0.9
    country.activities.published.find_each do |activity|
      add activity_path(activity), lastmod: activity.updated_at
    end
    #
    # Add badges
    add badges_path, changefreq: 'daily'
    Badge.find_each do |badge|
      add badge_path(badge)
    end
    #
    # Add clubs
    add clubs_path, changefreq: 'daily'
    country.clubs.find_each do |club|
      add club_path(club), changefreq: 'daily'
      add last_week_club_path(club)
    end
  end
end
