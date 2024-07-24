# frozen_string_literal: true

RSpec.describe Telegram::Notification::AfterReuniteJob do
  it 'performs immediately' do
    expect { described_class.perform_later(1) }.to have_enqueued_job.on_queue('low').at(:no_wait)
  end
end
