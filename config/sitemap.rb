Country.find_each do |country|
  SitemapGenerator::Sitemap.default_host = "https://s95.#{country.code}"
  SitemapGenerator::Sitemap.sitemaps_path = "sitemaps/#{country.code}"

  SitemapGenerator::Sitemap.create do
    # Put links creation logic here.
    #
    # The root path '/' and sitemap index file are added automatically for you.
    # Links are added to the Sitemap in the order they are specified.
    #
    # Usage: add(path, options={})
    #        (default options are used if you don't specify)
    #
    # Defaults: priority: 0.5, changefreq: 'weekly', lastmod: Time.now, host: default_host
    #
    # Add '/pages'
    Dir.glob('app/views/pages/*.html.erb').each do |file|
      page = File.basename(file, '.html.erb')
      next if page.starts_with? '_'

      add page_path(page)
    end
    # Add '/top_results'
    add top_results_path
    # Add all events:
    country.events.find_each do |event|
      add event_path(event.code_name), lastmod: event.updated_at
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
