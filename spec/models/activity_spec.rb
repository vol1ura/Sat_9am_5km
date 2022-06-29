# frozen_string_literal: true

RSpec.describe Activity, type: :model do
  it { is_expected.not_to be_valid }

  it 'valid with event and date' do
    activity = build :activity
    expect(activity).to be_valid
  end
end
