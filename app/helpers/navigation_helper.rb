# frozen_string_literal: true

module NavigationHelper
  def nav_label(key)
    scope = "navbars.top.#{key}"
    t(scope, default: t("navbars.about_s95.#{key}", default: key.to_s.humanize))
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

  def nav_active?(item)
    return false unless (rule = Navigation::ACTIVE_RULES[item[:key]])

    nav_matches_active_rule?(rule)
  end

  def locale_options
    [[:en, 'English', '🇬🇧'], [:ru, 'Русский', '🇷🇺'], [:sr, 'Srpski', '🇷🇸']]
  end

  def locale_switch_path(locale)
    opts = { only_path: true, params: request.query_parameters.except(:lang) }
    opts[:lang] = (locale == domain_locale ? nil : locale)
    url_for(opts)
  end

  def page_subnav_link_class(active: false)
    ['page-subnav-link', ('page-subnav-link--active' if active)].compact.join(' ')
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

  def nav_sheet_action_class
    'flex w-full items-center gap-3 rounded-lg px-3 py-2.5 text-sm text-ink hover:bg-accent-subtle'
  end

  def nav_desktop_link_class(active: false)
    base = 'shrink-0 whitespace-nowrap rounded-md px-2 py-2 text-sm font-medium xl:px-3'
    nav_menu_link_class(
      active: active,
      base: base,
      active_classes: 'bg-accent-subtle text-accent',
      inactive_classes: 'text-ink hover:bg-accent-subtle',
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

  def nav_menu_link_class(active:, base:, active_classes:, inactive_classes:)
    [base, active ? active_classes : inactive_classes].join(' ')
  end

  private

  def nav_matches_active_rule?(rule)
    (!rule[:signed_in] || user_signed_in?) &&
      controller_name.in?(Array(rule[:controller])) &&
      (!rule.key?(:action) || action_name.in?(Array(rule[:action]))) &&
      (!rule.key?(:page) || params[:page] == rule[:page])
  end
end
