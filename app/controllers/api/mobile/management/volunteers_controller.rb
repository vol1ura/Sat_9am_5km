# frozen_string_literal: true

module API
  module Mobile
    module Management
      class VolunteersController < AuthenticatedController
        before_action :find_activity
        before_action :find_volunteer, only: %i[update destroy]
        before_action :authorize_director!
        before_action :ensure_revision!

        def create
          @activity.with_lock do
            @activity.volunteers.create!(
              athlete: athlete_from_code(params.expect(:athlete_code)),
              role: params.expect(:role),
              comment: params[:comment],
            )
          end
          head :created
        end

        def update
          @activity.with_lock do
            @volunteer.role = params[:role] if params.key?(:role)
            @volunteer.comment = params[:comment] if params.key?(:comment)
            @volunteer.save!
          end
          head :no_content
        end

        def destroy
          @activity.with_lock { @volunteer.destroy! }
          head :no_content
        end

        private

        def find_activity
          @activity = manageable_activities.find(params.expect(:activity_id))
        end

        def find_volunteer
          @volunteer = @activity.volunteers.find(params.expect(:id))
        end

        def authorize_director!
          subject = @volunteer || Volunteer.new(activity: @activity)
          action = action_name.to_sym
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
          code = raw_code.to_s.delete_prefix('A').to_i
          raise ActiveRecord::RecordNotFound unless code.positive?

          Athlete.find_by!(**Athlete::PersonalCode.new(code).to_params)
        end
      end
    end
  end
end
