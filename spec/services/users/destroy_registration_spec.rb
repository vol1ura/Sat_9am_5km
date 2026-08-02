# frozen_string_literal: true

RSpec.describe Users::DestroyRegistration do
  subject(:call) { described_class.call(user) }

  let(:user) { create(:user, :with_athlete) }

  it 'destroys user and athlete without results or volunteering' do
    athlete = user.athlete

    expect { call }.to change(User, :count).by(-1)
    expect(Athlete).not_to exist(id: athlete.id)
  end

  it 'keeps athlete with results' do
    athlete = user.athlete
    create(:result, athlete:)

    expect { call }.to change(User, :count).by(-1)
    expect(Athlete).to exist(id: athlete.id)
    expect(athlete.reload.user).to be_nil
  end

  it 'keeps athlete with volunteering' do
    athlete = user.athlete
    create(:volunteer, athlete:)

    expect { call }.to change(User, :count).by(-1)
    expect(Athlete).to exist(id: athlete.id)
  end
end
