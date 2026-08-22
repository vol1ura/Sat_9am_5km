# frozen_string_literal: true

module Layout
  class FooterComponent < ApplicationComponent
    # rubocop:disable Metrics/MethodLength
    def contact_links
      [
        {
          url: Rails.configuration.telegram[top_level_domain],
          icon: 'fa-brands fa-telegram',
          title: t('navbars.bottom.telegram_title'),
          label: 'Telegram',
          external: true,
        },
        {
          url: 'https://vk.com/s95ru',
          icon: 'fa-brands fa-vk',
          title: t('navbars.bottom.vk_title'),
          label: 'VK',
          external: true,
        },
        {
          url: "mailto:#{ENV.fetch('INFO_EMAIL')}",
          icon: 'fa fa-envelope-open',
          title: t('navbars.bottom.send_email'),
          label: 'Email',
          external: true,
        },
        {
          url: page_path(page: 'feedback'),
          icon: 'fa-regular fa-comment-dots',
          title: t('navbars.bottom.feedback'),
          label: t('navbars.about_s95.feedback'),
          external: false,
        },
        {
          url: 'https://github.com/vol1ura/Sat_9am_5km',
          icon: 'fa-brands fa-github',
          title: t('navbars.bottom.github_title'),
          label: 'GitHub',
          external: true,
        },
      ]
    end
    # rubocop:enable Metrics/MethodLength

    def social_icon_class
      'flex h-10 w-10 items-center justify-center rounded-full border border-line ' \
        'bg-surface text-ink-muted hover:border-accent hover:text-accent'
    end
  end
end
