# frozen_string_literal: true

RSpec.describe MobilePairingCode do
  let(:user) { create(:user, :with_athlete) }

  it 'generates a six-digit, single-use code' do
    code = described_class.generate_for!(user)
    pairing = user.mobile_pairing_codes.active.last

    expect(code).to match(/\A\d{6}\z/)
    expect(pairing.consume!(code)).to be true
    expect(pairing.reload).to be_consumed_at
    expect(pairing.consume!(code)).to be false
  end

  it 'expires after five minutes' do
    code = described_class.generate_for!(user)
    pairing = user.mobile_pairing_codes.last

    travel 6.minutes
    expect(pairing.consume!(code)).to be false
  end

  it 'invalidates the previous code and locks after failed attempts' do
    described_class.generate_for!(user)
    current_code = described_class.generate_for!(user)
    pairing = user.mobile_pairing_codes.last

    described_class::MAX_FAILED_ATTEMPTS.times { pairing.consume!('wrong') }

    expect(user.mobile_pairing_codes.first).to be_consumed_at
    expect(pairing.reload.failed_attempts).to eq described_class::MAX_FAILED_ATTEMPTS
    expect(pairing.consume!(current_code)).to be false
  end
end
