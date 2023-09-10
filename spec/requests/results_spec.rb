RSpec.describe 'results' do
  describe 'GET /top_results' do
    before do
      activities_list = create_list(:activity, 4, published: true)
      activities_list.each do |activity|
        create_list(:result, 3, activity:)
      end
    end

    it 'renders successful response' do
      get top_results_url
      expect(response).to be_successful
    end
  end
end
