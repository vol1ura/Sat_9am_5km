RSpec.describe '/admin/volunteers', type: :request do
  let(:user) { create(:user) }
  let(:event) { create :event }
  let(:activity) { create :activity, event: event }

  before do
    create :permission, user: user, action: 'manage', subject_class: 'Volunteer', event_id: event.id
    sign_in user
  end

  describe 'GET /admin/volunteers' do
    it 'renders a successful response' do
      create_list :volunteer, 3, activity: activity
      get admin_activity_volunteers_url(activity)
      expect(response).to be_successful
    end
  end

  describe 'GET /admin/volunteers/1' do
    it 'renders a successful response' do
      volunteer = create :volunteer, activity: activity
      get admin_activity_volunteer_url(activity, volunteer)
      expect(response).to be_successful
    end
  end

  describe 'POST /admin/volunteers' do
    let(:activity) { create :activity }
    let(:athlete) { create :athlete }
    let(:valid_attributes) do
      {
        parkrun_code: athlete.parkrun_code,
        volunteer: { activity_id: activity.id, role: Volunteer::ROLES.keys.sample }
      }
    end

    it 'redirects unauthorized user' do
      user.permissions = []
      post admin_activity_volunteers_url(activity), params: valid_attributes
      expect(response).to redirect_to(root_url)
    end

    context 'when user is admin' do
      before do
        user.admin!
      end

      it 'creates a new volunteer' do
        expect do
          post admin_activity_volunteers_url(activity), params: valid_attributes
        end.to change(Volunteer, :count).by(1)
      end

      it "redirects to the volunteer's show page" do
        post admin_activity_volunteers_url(activity), params: valid_attributes
        expect(response).to redirect_to(admin_activity_volunteer_url(activity, Volunteer.last))
      end
    end
  end
end
