RSpec.describe Athlete, type: :model do
  it 'invalid without name' do
    athlete = build :athlete, name: nil
    expect(athlete).not_to be_valid
  end

  it 'invalid with existing parkrun_code' do
    parkrun_code = Faker::Number.number(digits: 6)
    create :athlete, parkrun_code: parkrun_code
    another_athlete = build :athlete, parkrun_code: parkrun_code
    expect(another_athlete).not_to be_valid
  end
end
