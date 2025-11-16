# frozen_string_literal: true

RSpec.describe Badge do
  it { is_expected.not_to be_valid }

  it 'valid with name and picture' do
    badge = described_class.new(name: Faker::Books::Dune.title, conditions: Faker::Lorem.paragraph)
    badge.image.attach(
      io: File.open('spec/fixtures/files/default.png'),
      filename: 'default.png',
    )
    expect(badge).to be_valid
  end
end
