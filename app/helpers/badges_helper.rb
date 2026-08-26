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
end
