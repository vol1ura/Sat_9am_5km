# frozen_string_literal: true

class Contact < ApplicationRecord
  belongs_to :event

  validates :link, presence: true, format: { with: /\A[^<>]+\z/ }
  validates :contact_type, presence: true, uniqueness: { scope: :event_id }

  enum contact_type: {
    map_link: 0, phone: 1, tg_channel: 2, tg_chat: 3, vk: 4,
    zen: 5, instagram: 6, facebook: 7, strava: 8, email: 9
  }
end
