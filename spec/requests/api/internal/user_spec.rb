# frozen_string_literal: true

RSpec.describe '/api/internal/user' do
  describe 'POST /api/internal/user' do
    let(:athlete_attributes) do
      {
        athlete: {
          name: Faker::Name.name,
          parkrun_code: Faker::Number.number(digits: 7),
        },
      }
    end

    let(:user_attributes) do
      {
        user: {
          first_name: Faker::Name.first_name,
          last_name: Faker::Name.last_name,
          male: true,
          telegram_id: Faker::Number.number(digits: 8),
          telegram_user: Faker::Internet.username,
        },
      }
    end

    it 'renders successful response' do
      post api_internal_user_path, params: user_attributes.merge(athlete_attributes), as: :json
      expect(response).to be_successful
    end

    it 'renders response with error' do
      post api_internal_user_path,
           params: user_attributes.merge(athlete_attributes).merge(user: { first_name: 'John', last_name: 'Doe' }),
           as: :json
      expect(response).to have_http_status :unprocessable_entity
    end

    it 'creates user with athlete' do
      expect do
        post api_internal_user_path, params: user_attributes.merge(athlete_attributes), as: :json
      end.to change(User, :count).by(1).and change(Athlete, :count).by(1)
    end

    it 'creates user with linked athlete' do
      athlete = create(:athlete)
      expect do
        post api_internal_user_path, params: user_attributes.merge(athlete_id: athlete.id), as: :json
      end.to change(User, :count).by(1)
    end
  end
end
