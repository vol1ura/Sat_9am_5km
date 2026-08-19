# frozen_string_literal: true

module BadgesHelper
  def badge_hub_path(badge)
    return achievements_badges_path unless badge.funrun_kind?

    if badge.received_date < Badge.funrun_archive_cutoff
      archive_badges_path
    else
      funruns_badges_path
    end
  end

  def badge_hub_description
    safe_join([tag.p(t('badges.index.how_to_get')), tag.p(t('badges.index.about_badges'))])
  end
end
