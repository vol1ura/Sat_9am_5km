# frozen_string_literal: true

RSpec.describe MobileSession do
  let(:user) { create(:user, :with_athlete) }

  it 'issues and authenticates an opaque token without storing it' do
    session, token = described_class.issue_for!(user, device_name: 'iPhone')

    expect(session.token_digest).to eq Digest::SHA256.hexdigest(token)
    expect(session.token_digest).not_to eq token
    expect(described_class.authenticate(token)).to eq session
  end

  it 'rejects revoked and expired sessions' do
    session, token = described_class.issue_for!(user)
    session.revoke!
    expect(described_class.authenticate(token)).to be_nil

    _session, expiring_token = described_class.issue_for!(user)
    travel(described_class::TTL + 1.minute)
    expect(described_class.authenticate(expiring_token)).to be_nil
  end
end
