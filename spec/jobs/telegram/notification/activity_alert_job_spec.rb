# frozen_string_literal: true

RSpec.describe Telegram::Notification::ActivityAlertJob do
  let(:activity) { create(:activity) }

  before do
    create(:volunteer, activity: activity, athlete: create(:athlete, :with_user), role: 'director')
    create(:volunteer, activity: activity, athlete: create(:athlete, :with_user), role: 'results_handler')
    allow(Telegram::Notification::User::Message).to receive(:call)
  end

  it 'informs athlete' do
    described_class.perform_now(activity.id, %w[director results_handler], 'test')
    expect(Telegram::Notification::User::Message).to have_received(:call).twice
  end
end
