# frozen_string_literal: true

RSpec.describe FunrunAwardingJob do
  let(:activity) { create(:activity) }
  let(:athlete) { create(:athlete) }
  let(:volunteer) { create(:athlete) }
  let(:badge) { create(:badge, kind: :funrun, received_date: received_date) }
  let(:received_date) { activity.date }

  before do
    create(:result, activity:, athlete:)
    create(:volunteer, activity: activity, athlete: volunteer)
  end

  shared_examples 'awarding' do
    it 'awards athlete by badge' do
      expect do
        described_class.perform_now(activity.id, badge.id)
      end
        .to change { athlete.trophies.exists?(badge:) }.from(false).to(true)
        .and change { volunteer.trophies.exists?(badge:) }.from(false).to(true)
    end
  end

  shared_examples 'no awarding' do
    it 'does not award athlete' do
      expect do
        described_class.perform_now(activity.id, badge.id)
      end
        .not_to(change { athlete.reload.trophies.count })
    end
  end

  it_behaves_like 'awarding'

  context 'with jubilee badge' do
    let(:badge) { create(:badge, kind: :jubilee_participating, info: { threshold: activity.number }) }

    it_behaves_like 'awarding'
  end

  context 'when athlete already has this badge' do
    before { create(:trophy, badge:, athlete:) }

    it_behaves_like 'no awarding'
  end

  context 'when funrun badge date is mismatched with activity date' do
    let(:received_date) { activity.date - 1.day }

    it_behaves_like 'no awarding'
  end
end
