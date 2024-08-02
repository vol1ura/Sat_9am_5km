# frozen_string_literal: true

RSpec.describe '/admin/newsletters' do
  let(:user) { create(:user, :admin) }

  before { sign_in user }

  describe 'GET /admin/newsletters' do
    it 'renders a successful response' do
      create_list(:newsletter, 2)
      get admin_newsletters_url
      expect(response).to be_successful
    end
  end

  describe 'GET /admin/newsletters/1' do
    it 'renders a successful response' do
      newsletter = create(:newsletter)
      get admin_newsletter_url(newsletter)
      expect(response).to be_successful
    end
  end

  describe 'POST /admin/newsletters' do
    let(:valid_attributes) do
      {
        newsletter: {
          body: Faker::Lorem.paragraph,
        },
      }
    end

    it 'creates a new newsletter' do
      expect do
        post admin_newsletters_url, params: valid_attributes
      end.to change(Newsletter, :count).by(1)
    end
  end

  describe 'POST /admin/newsletters/1/notify' do
    before { allow(Telegram::Notification::Newsletter).to receive(:call) }

    it 'redirects to show page' do
      newsletter = create(:newsletter)
      post notify_admin_newsletter_url(newsletter)
      expect(response).to redirect_to(admin_newsletter_url(newsletter))
    end
  end
end
