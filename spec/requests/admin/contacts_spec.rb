RSpec.describe '/admin/contacts', type: :request do
  let(:user) { create(:user) }
  let(:event) { create(:event) }

  before do
    FactoryBot.rewind_sequences
    sign_in user
  end

  describe 'GET /admin/contacts' do
    it 'renders a successful response' do
      create_list :contact, 3, event: event
      get admin_event_contacts_url(event)
      expect(response).to be_successful
    end
  end

  describe 'GET /admin/contacts/1' do
    it 'renders a successful response' do
      contact = create :contact, event: event
      get admin_event_contact_url(event, contact)
      expect(response).to be_successful
    end
  end
end
