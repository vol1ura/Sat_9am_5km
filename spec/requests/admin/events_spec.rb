RSpec.describe '/admin/events', type: :request do
  let(:user) { create(:user) }

  before do
    user.admin!
    sign_in user
  end

  describe 'GET /admin/events' do
    it 'renders a successful response' do
      create_list :event, 3
      get admin_events_url
      expect(response).to be_successful
    end
  end

  describe 'GET /admin/events/1' do
    it 'renders a successful response' do
      event = create :event
      get admin_event_url(event)
      expect(response).to be_successful
    end
  end

  describe 'GET /admin/events/1/edit' do
    let(:event) { create :event }

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
          town: Faker::Address.city,
          place: Faker::Address.street_name
        }
      }
    end

    it 'creates a new event' do
      expect do
        post admin_events_url, params: valid_attributes
      end.to change(Event, :count).by(1)
    end
  end
end
