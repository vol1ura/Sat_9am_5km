# frozen_string_literal: true

RSpec.describe Users::AuthToken do
  subject(:service) { described_class.new(user) }

  let(:user) { create(:user, auth_token:, auth_token_expires_at:) }
  let(:auth_token) { nil }
  let(:auth_token_expires_at) { nil }

  describe '#generate!' do
    it 'updates user with new auth token and expiration time' do
      expect { service.generate! }.to change { user.reload.auth_token }.from(nil)
      expect(user.auth_token_expires_at).to be > Time.current
      expect(user.auth_token_expires_at).to be < 3.minutes.from_now
    end
  end

  describe '#expire!' do
    let(:auth_token) { 'some_token' }
    let(:auth_token_expires_at) { 1.hour.from_now }

    it 'clears auth token and expiration time' do
      expect { service.expire! }
        .to change { user.reload.auth_token }.to(nil)
        .and change(user, :auth_token_expires_at).to(nil)
    end
  end

  describe '#valid?' do
    context 'without user' do
      let(:user) { nil }

      it { is_expected.not_to be_valid }
    end

    context 'when user has no auth token' do
      it { is_expected.not_to be_valid }
    end

    context 'when auth token is expired' do
      let(:auth_token) { 'some_token' }
      let(:auth_token_expires_at) { 1.second.ago }

      it { is_expected.not_to be_valid }
    end

    context 'when auth token is valid' do
      let(:auth_token) { 'some_token' }
      let(:auth_token_expires_at) { 1.minute.from_now }

      it { is_expected.to be_valid }
    end
  end
end
