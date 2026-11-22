# frozen_string_literal: true

module API
  module Mobile
    module Management
      class ActivitiesController < AuthenticatedController
        before_action :find_activity, only: %i[show mode publication_readiness publish]
        before_action :ensure_activity_access!, only: %i[show mode publication_readiness publish]

        def upcoming
          @activity = accessible_activities.order(:date, :id).first
          return head :no_content unless @activity

          render_activity
        end

        def show
          render_activity
        end

        def mode
          return unless director_authorized?(:update, @activity)
          return unless revision_current?(@activity)

          automatic = ActiveModel::Type::Boolean.new.cast(params.expect(:automatic))
          if automatic != @activity.token?
            unless @activity.mode_switchable?
              return render json: { error: 'mode_not_switchable' }, status: :unprocessable_content
            end

            Activities::ToggleMode.call(@activity, automatic:)
            @activity.reload
          end

          render_activity
        end

        def publication_readiness
          return unless director_authorized?(:update, @activity)

          render :publication_readiness
        end

        def publish
          return unless director_authorized?(:update, @activity)
          return unless revision_current?(@activity)

          errors = Activities::Publish.call(@activity)

          if errors.empty?
            @activity.reload
            render_activity
          else
            render json: { error: 'not_ready', blockers: errors }, status: :unprocessable_content
          end
        end

        private

        def find_activity
          @activity = manageable_activities.find(params.expect(:id))
        end

        def accessible_activities
          manageable_activities
            .where(date: Date.current..)
            .where(id: Volunteer.where(athlete: current_user.athlete).select(:activity_id))
        end

        def ensure_activity_access!
          return if Volunteer.exists?(activity: @activity, athlete: current_user.athlete)

          render json: { error: 'forbidden' }, status: :forbidden
        end

        def director?(activity)
          Volunteer.exists?(activity: activity, athlete: current_user.athlete, role: :director)
        end

        def allowed?(action, subject)
          director?(subject.is_a?(Activity) ? subject : subject.activity) &&
            Ability.new(current_user).can?(action, subject)
        end

        def director_authorized?(action, subject)
          return true if allowed?(action, subject)

          render json: { error: 'forbidden' }, status: :forbidden
          false
        end

        def revision_current?(activity)
          return true if params[:revision].blank? || params[:revision] == activity.updated_at.iso8601(6)

          render json: { error: 'conflict', revision: activity.updated_at.iso8601(6) }, status: :conflict
          false
        end

        def capabilities(activity)
          {
            manage_results: allowed?(:manage, Result.new(activity:)),
            manage_volunteers: allowed?(:manage, Volunteer.new(activity:)),
            toggle_mode: allowed?(:update, activity),
            publish: allowed?(:update, activity),
          }
        end

        def render_activity
          @capabilities = capabilities(@activity)
          @volunteers = @activity.volunteers_roster.includes(:athlete)
          @results =
            if @capabilities[:manage_results]
              @activity.results.includes(:athlete).order(:position)
            else
              Result.none
            end
          render :show
        end
      end
    end
  end
end
