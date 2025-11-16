# frozen_string_literal: true

RSpec.describe '/volunteers' do
  let(:user) { create(:user) }
  let(:activity) { create(:activity, published: false, date: Date.tomorrow) }
  let(:athlete) { create(:athlete, parkrun_code: 1) }
  let(:volunteer) { create(:volunteer, activity:) }

  before do
    create(:permission, user: user, action: 'manage', subject_class: 'Volunteer', event: activity.event)
    sign_in user, scope: :user
  end

  describe 'GET /volunteers/new' do
    it 'renders a successful response' do
      get new_volunteer_url(activity_id: activity.id, role: Volunteer.roles.keys.sample)
      expect(response).to be_successful
    end
  end

  describe 'GET /volunteers/edit' do
    it 'renders a successful response' do
      get edit_volunteer_url(volunteer)
      expect(response).to be_successful
    end
  end

  describe 'POST /volunteers' do
    let(:valid_attributes) do
      {
        volunteer: {
          activity_id: activity.id,
          athlete_id: athlete.id,
          role: Volunteer.roles.keys.sample,
        },
      }
    end

    it 'creates a new volunteer' do
      expect do
        post volunteers_url, params: valid_attributes, as: :turbo_stream
      end.to change(Volunteer, :count).by(1)
      expect(response).to be_successful
    end
  end

  describe 'PATCH /volunteer' do
    let(:valid_attributes) do
      {
        volunteer: {
          activity_id: activity.id,
          athlete_id: athlete.id,
          role: volunteer.role,
        },
      }
    end

    it 'change athlete' do
      patch volunteer_url(volunteer), params: valid_attributes, as: :turbo_stream
      expect(response).to be_successful
      expect(volunteer.reload.athlete).to eq athlete
      expect(volunteer.athlete.going_to_event_id).to eq activity.event_id
    end
  end
end
