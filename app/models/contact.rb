# frozen_string_literal: true

class Contact < ApplicationRecord
  belongs_to :event

  validates :link, presence: true, format: { with: /\A[^<>]+\z/ }
  validates :contact_type, presence: true, uniqueness: { scope: :event_id }

  enum :contact_type, {
    map_link: 0, parking: 1, phone: 2, tg_channel: 3, tg_chat: 4,
    vk: 5, zen: 6, instagram: 7, facebook: 8, strava: 9, email: 10
  }, instance_methods: false
end
