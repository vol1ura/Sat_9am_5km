# frozen_string_literal: true

module Athletes
  class DuelsService < ApplicationService
    def initialize(athlete, friend_id: nil, limit: 50)
      @athlete = athlete
      @friend_id = friend_id&.to_i
      @limit = limit
    end

    def call
      return [] unless @athlete&.friends&.any?

      duels = find_duels
      group_and_sort_duels(duels)
    end

    private

    def find_duels
      duels = []
      Result
        .published
        .joins(:athlete)
        .includes(activity: :event, athlete: { user: :image_attachment })
        .where(athlete: friends_scope)
        .group_by(&:activity_id)
        .each_value do |results|
          next if results.size < 2
          next unless (user_result = results.find { |r| r.athlete_id == @athlete.id })

          friend_results = results.reject { |r| r.athlete_id == @athlete.id }
          friend_results.each { |friend_result| duels << create_duel_data(user_result, friend_result) }
        end

      duels
    end

    def friends_scope
      friend_ids = @athlete.friends.ids
      friend_ids = [@friend_id].select { |id| friend_ids.include? id } if @friend_id
      Athlete.where(id: [*friend_ids, @athlete.id])
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

      diff_seconds = (friend_result.total_time - user_result.total_time).abs.to_i

      Result.total_time(0, 0) + diff_seconds.seconds
    end

    def group_and_sort_duels(duels)
      # Сначала группируем по друзьям, потом сортируем и ограничиваем для каждого друга
      duels.group_by { |duel| duel[:friend_result].athlete }
        .transform_values do |friend_duels|
        # Сортируем дуэли каждого друга по дате (новые сначала)
        sorted_duels = friend_duels.sort_by { |duel| -duel[:date].to_time.to_i }

        {
          duels: sorted_duels.first(@limit), # Ограничиваем для отображения
          stats: calculate_friend_stats(sorted_duels), # Статистика по всем дуэлям
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
