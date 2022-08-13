RSpec.describe 'results', type: :request do
  describe 'GET /top_results' do
    before do
      activities_list = create_list :activity, 4, published: true
      activities_list.each do |activity|
        create_list :result, 3, activity: activity
      end
      Bullet.n_plus_one_query_enable = false
    end

    after do
      Bullet.n_plus_one_query_enable = true
    end

    it 'renders successful response' do
      get top_results_url
      expect(response).to be_successful
    end
  end
end
