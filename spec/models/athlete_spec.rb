RSpec.describe Athlete, type: :model do
  it { is_expected.to be_valid }

  it 'invalid with existing parkrun_code' do
    parkrun_code = Faker::Number.number(digits: 6)
    create :athlete, parkrun_code: parkrun_code
    another_athlete = build :athlete, parkrun_code: parkrun_code
    expect(another_athlete).not_to be_valid
  end

  it 'fills blank names' do
    athlete = build :athlete, name: nil
    expect { athlete.save }.to change(athlete, :name).to(Athlete::NOBODY)
  end

  describe '#gender' do
    context 'when male is true' do
      it 'returns "мужчина"' do
        athlete = create :athlete, male: true
        expect(athlete.gender).to eq 'мужчина'
      end
    end

    context 'when male is false' do
      it 'returns "женщина"' do
        athlete = create :athlete, male: false
        expect(athlete.gender).to eq 'женщина'
      end
    end

    context 'when male is nil' do
      it 'returns nil' do
        athlete = create :athlete, male: nil
        expect(athlete.gender).to be_nil
      end
    end
  end

  describe '#duplicates' do
    it 'finds duplicated athletes by name case insensitive' do
      create :athlete, name: 'Test Name'
      create :athlete, name: 'test NAME', parkrun_code: nil
      expect(described_class.duplicates.size).to eq 2
    end
  end

  describe '#find_or_scrape_by_code!' do
    context 'when such athlete already exists' do
      it 'returns athlete from database' do
        athlete = create :athlete
        expect(described_class.find_or_scrape_by_code!(athlete.parkrun_code)).to eq athlete
      end
    end

    context 'when such athlete is not exists' do
      let(:parkrun_code) { Faker::Number.number(digits: 6) }
      let(:athlete_name) { Faker::Name.name }

      before do
        stub_request(:get, "https://www.parkrun.com.au/results/athleteresultshistory/?athleteNumber=#{parkrun_code}")
          .to_return(status: 200, body:
            <<~BODY
              <html>
                <head></head>
                <body>
                  <div id="content" role="main">
                    <h2>#{athlete_name}</h2>
                  </div>
                </body>
              </html>
            BODY
          )
      end

      it 'parse parkrun site to find athlete' do
        athlete = create :athlete, name: Athlete::NOBODY, parkrun_code: parkrun_code
        described_class.find_or_scrape_by_code!(athlete.parkrun_code)
        expect(athlete.reload.name).to eq athlete_name
      end
    end
  end
end
