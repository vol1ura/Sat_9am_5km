# frozen_string_literal: true

RSpec.describe VkPhotos, type: :service do
  context 'when argument is nil' do
    before do
      stub_request(
        :get,
        %r{https://api\.vk\.com/method/photos.get\?access_token=[\d\w]+&album_id=\d+&owner_id=-\d+&v=5\.130},
      ).to_raise(StandardError)
    end

    it 'returns empty array' do
      expect(described_class.call(Faker::Number.between(from: 3, to: 10))).to eq []
    end
  end
end
