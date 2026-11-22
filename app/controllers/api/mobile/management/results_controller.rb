# frozen_string_literal: true

module API
  module Mobile
    module Management
      class ResultsController < AuthenticatedController
        before_action :find_activity
        before_action :find_result, only: %i[update destroy]
        before_action :authorize_director!
        before_action :ensure_revision!

        def create
          @activity.with_lock do
            position = params[:position].presence&.to_i || (@activity.results.maximum(:position).to_i + 1)
            @activity.results.where(position: position..).update_all('position = position + 1')
            @activity.results.create!(
              position: position,
              total_time: params[:total_time],
              athlete: athlete_from_code(params[:athlete_code]),
            )
          end
          head :created
        end

        def update
          attributes = {}
          attributes[:total_time] = params[:total_time] if params.key?(:total_time)
          attributes[:athlete] = athlete_from_code(params[:athlete_code]) if params.key?(:athlete_code)
          @activity.with_lock { @result.update!(attributes) }
          head :no_content
        end

        def destroy
          @activity.with_lock do
            position = @result.position
            @result.destroy!
            @activity.results.where(position: (position + 1)..).update_all('position = position - 1')
            @activity.updated_at = Time.current
            @activity.save!
          end
          head :no_content
        end

        def reorder
          results = @activity.results.includes(:athlete).order(:position).to_a
          athletes = athletes_from_order(results)
          return unless athletes

          reassign_athletes!(athletes)
          head :no_content
        end

        private

        def athletes_from_order(results)
          athlete_codes = Array(params[:athlete_codes])
          if athlete_codes.length != results.length
            render json: { error: 'invalid_athlete_order' }, status: :unprocessable_content
            return
          end

          athletes = athlete_codes.map { |code| athlete_from_code(code) }
          athlete_ids = athletes.compact.map(&:id)
          return athletes if athlete_ids.uniq.length == athlete_ids.length

          render json: { error: 'duplicated_athletes' }, status: :unprocessable_content
          nil
        end

        def reassign_athletes!(athletes)
          @activity.with_lock do
            @activity.results.update_all(athlete_id: nil)
            cleared_results = @activity.results.order(:position).to_a
            cleared_results.each_with_index do |result, index|
              result.update!(athlete: athletes[index])
            end
            @activity.updated_at = Time.current
            @activity.save!
          end
        end

        def find_activity
          @activity = manageable_activities.find(params.expect(:activity_id))
        end

        def find_result
          @result = @activity.results.find(params.expect(:id))
        end

        def authorize_director!
          subject = @result || Result.new(activity: @activity)
          action = action_name == 'reorder' ? :update : action_name.to_sym
          allowed =
            Volunteer.exists?(activity: @activity, athlete: current_user.athlete, role: :director) &&
            Ability.new(current_user).can?(action, subject)
          render(json: { error: 'forbidden' }, status: :forbidden) unless allowed
        end

        def ensure_revision!
          return if performed?
          return if params[:revision].blank? || params[:revision] == @activity.updated_at.iso8601(6)

          render json: { error: 'conflict', revision: @activity.updated_at.iso8601(6) }, status: :conflict
        end

        def athlete_from_code(raw_code)
          return if raw_code.blank?

          code = raw_code.to_s.delete_prefix('A').to_i
          Athlete.find_or_scrape_by_code!(code)
        end
      end
    end
  end
end
