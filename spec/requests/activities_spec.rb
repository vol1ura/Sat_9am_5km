RSpec.describe '/activities', type: :request do
  let(:valid_attributes) do
    skip('Add a hash of attributes valid for your model')
  end

  let(:invalid_attributes) do
    skip('Add a hash of attributes invalid for your model')
  end

  describe 'GET /index' do
    it 'renders a successful response' do
      create_list :activity, 3
      get activities_url
      expect(response).to be_successful
    end
  end

  describe 'GET /show' do
    it 'renders a successful response' do
      activity = Activity.create! valid_attributes
      get activity_url(activity)
      expect(response).to be_successful
    end
  end
end
