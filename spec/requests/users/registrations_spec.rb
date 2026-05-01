# frozen_string_literal: true

RSpec.describe '/user' do
  describe 'POST /user' do
    let(:valid_params) do
      {
        user: {
          first_name: 'Ivan',
          last_name: 'Ivanov',
          email: 'ivan@example.com',
          policy_accepted: '1',
          athlete_attributes: { gender: 'male' },
        },
      }
    end

    def field_invalid?(name)
      doc = Nokogiri::HTML(response.body)
      doc.css(%(input[name="#{name}"].is-invalid)).any?
    end

    context 'with all required fields filled in' do
      it 'creates the user and redirects to the sign-in page', :aggregate_failures do
        expect { post user_registration_path, params: valid_params }.to change(User, :count).by(1)

        expect(response).to redirect_to(new_user_session_path)
        user = User.last
        expect(user).to have_attributes(
          first_name: 'Ivan',
          last_name: 'Ivanov',
          email: 'ivan@example.com',
          policy_accepted: true,
        )
        expect(user.athlete.gender).to eq 'male'
      end
    end

    context 'without policy_accepted' do
      let(:params) { valid_params.deep_merge(user: { policy_accepted: '0' }) }

      it 'does not create the user and highlights the checkbox with an error', :aggregate_failures do
        expect { post user_registration_path, params: }.not_to change(User, :count)

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include(I18n.t('devise.registrations.new.policy_required'))
        expect(field_invalid?('user[policy_accepted]')).to be true
      end
    end

    context 'without gender' do
      let(:params) { valid_params.deep_merge(user: { athlete_attributes: { gender: '' } }) }

      it 'does not create the user and highlights gender with an error', :aggregate_failures do
        expect { post user_registration_path, params: }.not_to change(User, :count)

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include(I18n.t('devise.registrations.new.gender_required'))
        expect(field_invalid?('user[athlete_attributes][gender]')).to be true
      end
    end

    context 'without first name' do
      let(:params) { valid_params.deep_merge(user: { first_name: '' }) }

      it 'does not create the user and highlights first name with an error', :aggregate_failures do
        expect { post user_registration_path, params: }.not_to change(User, :count)

        expect(response).to have_http_status(:unprocessable_content)
        expect(field_invalid?('user[first_name]')).to be true
      end
    end

    context 'without last name' do
      let(:params) { valid_params.deep_merge(user: { last_name: '' }) }

      it 'does not create the user and highlights last name with an error', :aggregate_failures do
        expect { post user_registration_path, params: }.not_to change(User, :count)

        expect(response).to have_http_status(:unprocessable_content)
        expect(field_invalid?('user[last_name]')).to be true
      end
    end

    context 'without email' do
      let(:params) { valid_params.deep_merge(user: { email: '' }) }

      it 'does not create the user and highlights email with an error', :aggregate_failures do
        expect { post user_registration_path, params: }.not_to change(User, :count)

        expect(response).to have_http_status(:unprocessable_content)
        expect(field_invalid?('user[email]')).to be true
      end
    end
  end
end
