# frozen_string_literal: true

describe Users::ImageCompressor do
  let(:user) { create(:user) }

  before do
    user.image.attach(io: File.open('spec/fixtures/files/default.png'), filename: 'avatar.png')
    described_class.call(user)
  end

  it 'compress image' do
    expect(user.reload.image.byte_size).to be < 50.kilobytes
  end
end
