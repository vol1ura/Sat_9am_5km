# frozen_string_literal: true

RSpec.describe '/admin/events' do
  let(:user) { create(:user) }

  before do
    user.admin!
    sign_in user
  end

  describe 'GET /admin/events' do
    it 'renders a successful response' do
      create_list(:event, 3)
      get admin_events_url
      expect(response).to be_successful
    end
  end

  describe 'GET /admin/events/1' do
    it 'renders a successful response' do
      event = create(:event)
      get admin_event_url(event)
      expect(response).to be_successful
    end
  end

  describe 'GET /admin/events/1/edit' do
    let(:event) { create(:event) }

    context 'when user is not authorized' do
      it 'redirects to root url' do
        user.update!(role: nil)
        get edit_admin_event_url(event)
        expect(response).to have_http_status :found
        expect(response).to redirect_to(root_url)
      end
    end

    context 'when user is authorized' do
      it 'renders form' do
        get edit_admin_event_url(event)
        expect(response).to be_successful
      end
    end
  end

  describe 'POST /admin/events' do
    let(:valid_attributes) do
      {
        event: {
          name: Faker::Team.name,
          code_name: Faker::Internet.slug(glue: '_'),
          description: Faker::Lorem.paragraph,
          town: Faker::Address.city,
          place: Faker::Address.street_name,
          place_description: Faker::Address.full_address,
          country_id: countries(:ru).id,
        },
      }
    end

    it 'creates a new event' do
      expect do
        post admin_events_url, params: valid_attributes
      end.to change(Event, :count).by(1)
    end
  end

  describe 'PATCH /admin/events/1' do
    let(:event) { create(:event) }
    let(:configured_renew_job) { instance_double(ActiveJob::ConfiguredJob, perform_later: true) }

    before do
      allow(RenewGoingToEventJob).to receive(:set).and_return(configured_renew_job)
      allow(Notification::EventCancellationJob).to receive(:perform_later)
    end

    it 'enqueues cancellation notification before renewing going athletes' do
      patch admin_event_url(event), params: { event: { active: false }, notify_cancellation: '1' }

      expect(Notification::EventCancellationJob).to have_received(:perform_later).with(event.id).ordered
      expect(RenewGoingToEventJob).to have_received(:set).with(queue: :sequential).ordered
      expect(configured_renew_job).to have_received(:perform_later).with(event.id).ordered
    end

    it 'enqueues only renew job when notifications are disabled' do
      patch admin_event_url(event), params: { event: { active: false }, notify_cancellation: '0' }

      expect(RenewGoingToEventJob).to have_received(:set).with(queue: :sequential)
      expect(configured_renew_job).to have_received(:perform_later).with(event.id)
      expect(Notification::EventCancellationJob).not_to have_received(:perform_later)
    end
  end
end
