# frozen_string_literal: true

RSpec.describe CompressUserImageJob do
  it 'performs immediately' do
    expect { described_class.perform_later(1) }.to have_enqueued_job.on_queue('low').at(:no_wait)
  end

  context 'with user' do
    let(:user) { create(:user) }

    before do
      allow(Users::ImageCompressor).to receive(:call)
      described_class.perform_now(user.id)
    end

    it 'runs compressor service' do
      expect(Users::ImageCompressor).to have_received(:call).with(user).once
    end
  end
end
