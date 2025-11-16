# frozen_string_literal: true

describe Users::ImageCompressor do
  let(:user) { create(:user) }
  let(:max_file_size) { 50.kilobytes }

  before do
    stub_const('Users::ImageCompressor::MAX_SIZE', max_file_size)
    user.image.attach(io: File.open('spec/fixtures/files/default.png'), filename: 'avatar.png')
    described_class.call(user)
  end

  it 'compresses image' do
    expect(user.reload.image.byte_size).to be < 50.kilobytes
  end

  context 'when file size is exceeded' do
    let(:max_file_size) { 10.kilobytes }

    it 'deletes image' do
      expect(user.reload.image).not_to be_attached
    end
  end
end
