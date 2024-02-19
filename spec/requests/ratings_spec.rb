# frozen_string_literal: true

RSpec.describe 'ratings' do
  describe 'GET /ratings/athletes' do
    before do
      Bullet.n_plus_one_query_enable = false
      create_list(:result, 2)

      get athletes_ratings_url
    end

    after do
      Bullet.n_plus_one_query_enable = true
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

  describe 'GET /ratings/volunteers' do
    before do
      Bullet.n_plus_one_query_enable = false
      create_list(:volunteer, 2)

      get volunteers_ratings_url
    end

    after do
      Bullet.n_plus_one_query_enable = true
    end

    it { expect(response).to be_successful }
  end
end
