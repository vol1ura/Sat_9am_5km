# frozen_string_literal: true

RSpec.describe '/admin/contacts' do
  let(:user) { create(:user, :admin) }
  let(:event) { create(:event) }

  before do
    FactoryBot.rewind_sequences
    sign_in user, scope: :user
  end

  describe 'GET /admin/events/1/contacts' do
    it 'renders a successful response' do
      create_list(:contact, 2, event:)
      get admin_event_contacts_url(event)
      expect(response).to be_successful
    end
  end

  describe 'GET /admin/events/1/contacts/1/edit' do
    it 'renders a successful response' do
      contact = create(:contact, event:)
      get edit_admin_event_contact_url(event, contact)
      expect(response).to be_successful
    end
  end

  describe 'POST /admin/events/1/contacts' do
    let(:valid_attributes) do
      {
        contact: {
          contact_type: :vk,
          link: Faker::Internet.url,
        },
      }
    end

    it 'creates a new contact' do
      expect do
        post admin_event_contacts_url(event), params: valid_attributes
      end.to change(Contact, :count).by(1)
    end
  end
end
