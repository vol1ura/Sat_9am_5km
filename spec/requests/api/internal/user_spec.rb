# frozen_string_literal: true

RSpec.describe '/api/internal/user' do
  let(:headers) do
    { 'Accept' => 'application/json' }
  end
  let(:athlete_attributes) do
    {
      athlete: {
        name: Faker::Name.name,
        parkrun_code: Faker::Number.number(digits: 7),
      },
    }
  end

  describe 'POST /api/internal/user' do
    let(:user_attributes) do
      {
        user: {
          first_name: Faker::Name.first_name,
          last_name: Faker::Name.last_name,
          email: Faker::Internet.email,
          password: Faker::Internet.password(min_length: 6),
          telegram_id: Faker::Number.number(digits: 8),
          telegram_user: Faker::Internet.username,
        },
      }
    end

    it 'renders successful response' do
      post api_internal_user_path, params: user_attributes.merge(athlete_attributes), headers: headers
      expect(response).to be_successful
    end

    it 'renders response with error' do
      post api_internal_user_path,
           params: user_attributes.merge(athlete_attributes).merge(user: { password: '12345' }),
           headers: headers
      expect(response).to have_http_status :unprocessable_entity
    end

    it 'creates user with athlete' do
      expect do
        post api_internal_user_path, params: user_attributes.merge(athlete_attributes), headers: headers
      end.to change(User, :count).by(1).and change(Athlete, :count).by(1)
    end

    it 'creates user with linked athlete' do
      athlete = create(:athlete)
      expect do
        post api_internal_user_path, params: user_attributes.merge(athlete_id: athlete.id), headers: headers
      end.to change(User, :count).by(1)
    end
  end

  describe 'PUT /api/internal/user' do
    let(:user) { create(:user) }
    let(:user_attributes) do
      {
        user_id: user.id,
        user: {
          telegram_id: Faker::Number.number(digits: 8),
          telegram_user: Faker::Internet.username,
        },
      }
    end

    it 'renders successful response' do
      put api_internal_user_path, params: user_attributes.merge(athlete_attributes), headers: headers
      expect(response).to be_successful
    end

    it 'links user with athlete' do
      expect do
        put api_internal_user_path, params: user_attributes.merge(athlete_attributes), headers: headers
      end.to change(Athlete, :count).by(1)
    end

    it 'creates user with linked athlete' do
      athlete = create(:athlete)
      put api_internal_user_path, params: user_attributes.merge(athlete_id: athlete.id), headers: headers
      expect(athlete.reload.user).to eq user
    end
  end
end
