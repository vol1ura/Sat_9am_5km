# frozen_string_literal: true

module Athletes
  class DuelsService < ApplicationService
    param :athlete, reader: :private
    option :friend_id, reader: :private, default: -> {}
    option :limit, reader: :private, default: -> { 50 }

    def call
      return [] if friend_ids.empty?

      duels = find_duels
      group_and_sort_duels(duels)
    end

    private

    def find_duels
      duels = []
      Result
        .published
        .joins(:athlete)
        .includes(activity: :event, athlete: { user: { image_attachment: :blob } })
        .where(athlete: friends_scope)
        .group_by(&:activity_id)
        .each_value do |results|
          next if results.size < 2
          next unless (user_result = results.find { |r| r.athlete_id == athlete.id })

          friend_results = results.reject { |r| r.athlete_id == athlete.id }
          friend_results.each { |friend_result| duels << create_duel_data(user_result, friend_result) }
        end

      duels
    end

    def friends_scope
      scoped_friend_ids = friend_id ? [friend_id].select { |id| friend_ids.include?(id) } : friend_ids
      Athlete.where(id: [*scoped_friend_ids, athlete.id])
    end

    def friend_ids
      @friend_ids ||= Friendship.where(athlete_id: athlete.id).pluck(:friend_id)
    end

    def create_duel_data(user_result, friend_result)
      activity = user_result.activity

      {
        id: "#{activity.id}_#{user_result.athlete_id}_#{friend_result.athlete_id}",
        date: activity.date,
        activity: activity,
        event: activity.event,
        user_result: user_result,
        friend_result: friend_result,
        winner: user_result.position < friend_result.position ? :user : :friend,
        time_difference: calculate_time_difference(user_result, friend_result),
        position_difference: (friend_result.position - user_result.position).abs,
      }
    end

    def calculate_time_difference(user_result, friend_result)
      return unless user_result.total_time && friend_result.total_time

      (friend_result.total_time - user_result.total_time).abs
    end

    def group_and_sort_duels(duels)
      duels.group_by { |duel| duel[:friend_result].athlete }
        .transform_values do |friend_duels|
        sorted_duels = friend_duels.sort_by { |duel| -duel[:date].to_time.to_i }

        {
          duels: sorted_duels.first(limit),
          stats: calculate_friend_stats(sorted_duels),
        }
      end
    end

    def calculate_friend_stats(friend_duels)
      total_duels = friend_duels.size
      user_wins = friend_duels.count { |duel| duel[:winner] == :user }
      friend_wins = friend_duels.count { |duel| duel[:winner] == :friend }

      {
        total_duels: total_duels,
        user_wins: user_wins,
        friend_wins: friend_wins,
        user_win_rate: total_duels.positive? ? (user_wins.to_f / total_duels * 100).round(1) : 0,
      }
    end
  end
end
