# frozen_string_literal: true

RSpec.describe Club do
  it { is_expected.not_to be_valid }

  it 'valid with name and country' do
    expect(described_class.new(name: Faker::Team.name, country_id: countries(:ru).id)).to be_valid
  end

  describe '#to_combobox_display' do
    it 'returns club name' do
      club = build(:club)
      expect(club.to_combobox_display).to eq(club.name)
    end
  end
end
