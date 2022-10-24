RSpec.describe '/user' do
  describe 'POST /user' do
    let(:user_attributes) do
      {
        user: {
          email: Faker::Internet.free_email,
          password: Faker::Internet.password(min_length: 6),
          telegram_id: Faker::Number.number(digits: 8),
          telegram_user: Faker::Internet.username
        }
      }
    end
    let(:athlete_attributes) do
      {
        athlete: {
          name: Faker::Name.name,
          parkrun_code: Faker::Number.number(digits: 7)
        }
      }
    end

    context 'when header api key is invalid' do
      it 'returns unauthorized response' do
        post user_path(format: :json),
             params: user_attributes.merge(athlete_attributes),
             headers: {
               'Accept' => 'application/json',
               'Authorization' => Faker::Crypto.sha256
             }
        expect(response).to have_http_status :unauthorized
      end
    end

    context 'with valid header api key' do
      let(:valid_headers) do
        {
          'Accept' => 'application/json',
          'Authorization' => Rails.application.credentials.internal_api_key
        }
      end

      it 'renders successful response' do
        post user_path(format: :json), params: user_attributes.merge(athlete_attributes), headers: valid_headers
        expect(response).to be_successful
      end

      it 'renders response with error' do
        post user_path(format: :json),
             params: user_attributes.merge(athlete_attributes).merge(user: { password: '12345' }),
             headers: valid_headers
        expect(response).to have_http_status :unprocessable_entity
      end

      it 'creates user with athlete' do
        expect do
          post user_path(format: :json), params: user_attributes.merge(athlete_attributes), headers: valid_headers
        end.to change(User, :count).by(1).and change(Athlete, :count).by(1)
      end

      it 'creates user with linked athlete' do
        athlete = create(:athlete)
        expect do
          post user_path(format: :json), params: user_attributes.merge(athlete_id: athlete.id), headers: valid_headers
        end.to change(User, :count).by(1)
      end
    end
  end

  describe 'PUT /user' do
    let(:user) { create(:user) }
    let(:athlete_attributes) do
      {
        athlete: {
          name: Faker::Name.name,
          parkrun_code: Faker::Number.number(digits: 7)
        }
      }
    end

    context 'when header api key is invalid' do
      it 'returns unauthorized response' do
        put user_path(format: :json),
            params: { user_id: user.id }.merge(athlete_attributes),
            headers: {
              'Accept' => 'application/json',
              'Authorization' => Faker::Crypto.sha256
            }
        expect(response).to have_http_status :unauthorized
      end
    end

    context 'with valid header api key' do
      let(:valid_headers) do
        {
          'Accept' => 'application/json',
          'Authorization' => Rails.application.credentials.internal_api_key
        }
      end
      let(:user_attributes) do
        {
          user_id: user.id,
          user: {
            telegram_id: Faker::Number.number(digits: 8),
            telegram_user: Faker::Internet.username
          }
        }
      end

      it 'renders successful response' do
        put user_path(format: :json), params: user_attributes.merge(athlete_attributes), headers: valid_headers
        expect(response).to be_successful
      end

      it 'links user with athlete' do
        expect do
          put user_path(format: :json), params: user_attributes.merge(athlete_attributes), headers: valid_headers
        end.to change(Athlete, :count).by(1)
      end

      it 'creates user with linked athlete' do
        athlete = create(:athlete)
        put user_path(format: :json), params: user_attributes.merge(athlete_id: athlete.id), headers: valid_headers
        expect(athlete.reload.user).to eq user
      end
    end
  end
end
