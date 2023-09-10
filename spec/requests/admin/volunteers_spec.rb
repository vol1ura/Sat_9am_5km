RSpec.describe '/admin/activities/1/volunteers' do
  let(:user) { create(:user) }
  let(:activity) { create(:activity) }

  before do
    create(:permission, user: user, action: 'manage', subject_class: 'Volunteer', event_id: activity.event_id)
    sign_in user
  end

  describe 'GET /admin/activities/1/volunteers' do
    before do
      create(:permission, user: user, action: 'manage', subject_class: 'VolunteeringPosition', event_id: activity.event_id)
    end

    it 'renders a successful response' do
      create_list(:volunteer, 3, activity: activity)
      get admin_activity_volunteers_url(activity)
      expect(response).to be_successful
    end

    context 'when user is admin' do
      before { user.admin! }

      it 'shows volunteers from not only allowed event' do
        volunteer = create(:volunteer)
        get admin_activity_volunteers_url(volunteer.activity)
        expect(response.body).to include volunteer.athlete.name
      end
    end
  end

  describe 'POST, PUT /admin/activities/1/volunteers' do
    let(:athlete) { create(:athlete) }
    let(:valid_attributes) do
      {
        volunteer: { athlete_id: athlete.id, role: Volunteer.roles.keys.sample },
      }
    end

    it 'redirects unauthorized user' do
      user.permissions = []
      post admin_activity_volunteers_url(activity), params: valid_attributes
      expect(response).to redirect_to(root_url)
    end

    context 'with authorized user' do
      it 'creates a new volunteer' do
        expect do
          post admin_activity_volunteers_url(activity), params: valid_attributes
        end.to change(Volunteer, :count).by(1)
      end

      it 'redirects to the volunteers index page of current activity' do
        post admin_activity_volunteers_url(activity), params: valid_attributes
        expect(response).to redirect_to(admin_activity_volunteers_url(activity))
      end
    end
  end

  describe 'PUT /admin/activities/1/volunteer/1' do
    let(:volunteer) { create(:volunteer, activity: activity) }
    let(:athlete) { create(:athlete) }
    let(:valid_attributes) do
      {
        volunteer: { athlete_id: athlete.id, role: Volunteer.roles.keys.sample },
      }
    end

    before do
      put admin_activity_volunteer_url(activity, volunteer), params: valid_attributes
    end

    it 'updates athlete in volunteer' do
      expect(volunteer.reload.athlete).to eq athlete
    end

    it 'redirects to the volunteers index page of current activity' do
      expect(response).to redirect_to(admin_activity_volunteers_url(activity))
    end
  end

  describe 'GET /admin/activities/1/volunteers.csv' do
    it 'downloads csv file' do
      create_list(:volunteer, 3, activity: activity)
      get admin_activity_volunteers_url(activity, format: :csv)
      expect(response).to be_successful
    end
  end

  describe 'POST /admin/activities/1/volunteers' do
    let!(:volunteer) { create(:volunteer, activity: activity) }
    let(:other_activity) { create(:activity, date: activity.date) }
    let(:invalid_attributes) do
      {
        volunteer: { athlete_id: volunteer.athlete_id, role: Volunteer.roles.keys.sample },
      }
    end

    it 'cannot create new volunteer' do
      expect do
        post(admin_activity_volunteers_url(other_activity), params: invalid_attributes)
      end.not_to change(Volunteer, :count)
    end
  end
end
