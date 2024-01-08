# frozen_string_literal: true

RSpec.describe Contact do
  it { is_expected.not_to be_valid }

  it 'valid with event, link and contact_type' do
    contact = build(:contact)
    expect(contact).to be_valid
  end
end
