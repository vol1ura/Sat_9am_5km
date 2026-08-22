# frozen_string_literal: true

RSpec.describe '/admin/volunteer_applications' do
  let(:user) { create(:user, :admin) }
  let(:application) { create(:volunteer_application) }

  before { sign_in user }

  describe 'GET /admin/activities/:activity_id/volunteer_applications' do
    it 'renders the applications queue' do
      application

      get admin_activity_volunteer_applications_url(application.activity)

      expect(response).to be_successful
    end

    context 'when the user organizes volunteers for the event' do
      let(:user) { create(:user) }

      before do
        create(:permission, user: user, action: 'manage', subject_class: 'Volunteer', event: application.activity.event)
      end

      it 'renders the applications queue' do
        get admin_activity_volunteer_applications_url(application.activity)

        expect(response).to be_successful
      end
    end
  end

  describe 'PUT /admin/activities/:activity_id/volunteer_applications/:id/approve' do
    before do
      create(:volunteering_position, event: application.activity.event, role: application.role, number: 1)
    end

    it 'approves the application and creates a volunteer' do
      expect do
        put approve_admin_activity_volunteer_application_url(application.activity, application)
      end.to change(Volunteer, :count).by(1)

      expect(application.reload).to be_approved
      expect(response).to redirect_to admin_activity_volunteer_applications_path(application.activity)
    end
  end

  describe 'PUT /admin/activities/:activity_id/volunteer_applications/:id/reject' do
    it 'rejects the application' do
      put reject_admin_activity_volunteer_application_url(application.activity, application)

      expect(application.reload).to be_rejected
      expect(response).to redirect_to admin_activity_volunteer_applications_path(application.activity)
    end
  end
end
