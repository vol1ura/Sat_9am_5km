RSpec.describe Club do
  it { is_expected.not_to be_valid }

  it 'valid with name' do
    club = described_class.new(name: Faker::Team.name)
    expect(club).to be_valid
  end
end
