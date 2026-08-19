# frozen_string_literal: true

RSpec.describe Badge do
  it { is_expected.not_to be_valid }

  it 'valid with name and picture' do
    badge = described_class.new(
      kind: :participating,
      name: Faker::Books::Dune.title,
      conditions: Faker::Lorem.paragraph,
    )
    badge.image.attach(
      io: File.open('spec/fixtures/files/default.png'),
      filename: 'default.png',
    )
    expect(badge).to be_valid
  end

  describe 'funrun badges' do
    let(:badge) do
      described_class.new(
        kind: :funrun,
        name: Faker::Books::Dune.title,
        conditions: Faker::Lorem.paragraph,
        received_date: received_date,
      )
    end

    before do
      badge.image.attach(
        io: File.open('spec/fixtures/files/default.png'),
        filename: 'default.png',
      )
    end

    context 'without received_date' do
      let(:received_date) { nil }

      it { expect(badge).not_to be_valid }
    end

    context 'with received_date' do
      let(:received_date) { Date.current }

      it { expect(badge).to be_valid }

      it 'is archived when older than cutoff' do
        badge.received_date = 3.years.ago.to_date
        expect(badge).to be_archived_funrun
      end
    end
  end
end
