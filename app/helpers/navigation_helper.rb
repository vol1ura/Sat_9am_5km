# frozen_string_literal: true

module NavigationHelper
  def nav_label(key)
    t(
      "navbars.top.#{key}",
      default: [:"navbars.about_s95.#{key}", :"navbars.contacts.#{key}", key.to_s.humanize],
    )
  end

  def nav_visible_items(items)
    Array(items).select { |item| item[:domains].blank? || item[:domains].include?(top_level_domain) }
  end

  def nav_path(item)
    return new_user_session_path if item[:key] == :profile && !user_signed_in?

    path_method = item[:path]
    return '#' unless path_method

    params = item[:params] || {}
    if path_method == :profile_path
      user_signed_in? ? athlete_path(current_user.athlete) : new_user_session_path
    else
      public_send(path_method, **params)
    end
  end

  def nav_item_link(item, html_class:)
    if item[:external]
      external_link_to nav_label(item[:key]), nav_external_url(item), class: html_class
    else
      link_to nav_label(item[:key]), nav_path(item), class: html_class
    end
  end

  def nav_active?(item)
    return item[:children].any? { |child| nav_active?(child) } if item[:children]
    return false unless (rule = Navigation::ACTIVE_RULES[item[:key]])

    nav_matches_active_rule?(rule)
  end

  def locale_switch_path(locale)
    opts = { only_path: true, params: request.query_parameters.except(:lang) }
    opts[:lang] = (locale == domain_locale ? nil : locale)
    url_for(opts)
  end

  def page_subnav_link_class(active: false, disabled: false)
    [
      'page-subnav-link',
      ('page-subnav-link--active' if active),
      ('page-subnav-link--disabled' if disabled),
    ].compact.join(' ')
  end

  def nav_dropdown_link_class(active: false)
    nav_menu_link_class(
      active: active,
      base: 'block rounded-md px-4 py-2 text-sm',
      active_classes: 'bg-accent-subtle font-medium text-accent',
      inactive_classes: 'text-ink hover:bg-accent-subtle',
    )
  end

  def nav_sheet_link_class(active: false)
    nav_menu_link_class(
      active: active,
      base: 'block rounded-lg px-3 py-2.5 text-sm',
      active_classes: 'bg-accent-subtle font-medium text-accent',
      inactive_classes: 'text-ink hover:bg-accent-subtle',
    )
  end

  def nav_desktop_link_class(active: false)
    base = 'shrink-0 whitespace-nowrap rounded-md px-2 py-2 text-sm font-medium xl:px-3'
    nav_menu_link_class(
      active: active,
      base: base,
      active_classes: 'bg-white/15 text-white',
      inactive_classes: 'text-white/80 hover:bg-white/10 hover:text-white',
    )
  end

  def nav_bottom_link_class(active: false)
    base = 'flex flex-1 flex-col items-center justify-center gap-0.5 text-xs'
    active ? "#{base} text-accent font-medium" : "#{base} text-ink-muted"
  end

  def dropdown_menu_class(align: :start, min_width: 'min-w-44')
    alignment = align == :end ? 'end-0' : 'left-0'
    [
      'absolute', alignment, 'top-[calc(100%-2px)] z-20 m-0 hidden', min_width,
      'list-none rounded-lg border border-line bg-surface-elevated py-1 shadow-lg',
    ].join(' ')
  end

  private

  def nav_menu_link_class(active:, base:, active_classes:, inactive_classes:)
    [base, active ? active_classes : inactive_classes].join(' ')
  end

  def nav_external_url(item)
    case item[:url]
    when :telegram then Rails.configuration.telegram[top_level_domain]
    when :mailto_info then "mailto:#{ENV.fetch('INFO_EMAIL')}"
    else item[:url]
    end
  end

  def nav_matches_active_rule?(rule)
    (!rule[:signed_in] || user_signed_in?) &&
      controller_name.in?(Array(rule[:controller])) &&
      (!rule.key?(:action) || action_name.in?(Array(rule[:action]))) &&
      (!rule.key?(:page) || params[:page] == rule[:page])
  end
end
