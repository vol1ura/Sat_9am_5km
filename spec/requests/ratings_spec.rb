# frozen_string_literal: true

RSpec.describe 'ratings' do
  describe 'GET /ratings?type=results' do
    before do
      create_list(:result, 2)

      get ratings_url(type: 'results')
    end

    it { expect(response).to be_successful }
  end

  describe 'GET /ratings/results' do
    before do
      activities_list = create_list(:activity, 2)
      activities_list.each do |activity|
        create_list(:result, 2, activity:)
      end

      get results_ratings_url
    end

    it { expect(response).to be_successful }
  end

  describe 'GET /ratings?type=volunteers' do
    before do
      create_list(:volunteer, 2)

      get ratings_url(type: 'volunteers', order: 'h_index')
    end

    it { expect(response).to be_successful }
  end
end
