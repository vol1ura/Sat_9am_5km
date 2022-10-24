RSpec.describe Badge do
  it { is_expected.not_to be_valid }

  it 'valid with name and picture link' do
    badge = described_class.new(
      name: Faker::Books::Dune.title,
      picture_link: Faker::File.dir(segment_count: 3, root: nil, directory_separator: '/')
    )
    expect(badge).to be_valid
  end
end
