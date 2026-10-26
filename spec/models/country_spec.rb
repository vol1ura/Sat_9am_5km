# frozen_string_literal: true

RSpec.describe Country do
  describe '#locale' do
    it 'returns the locale matching the country code' do
      expect(described_class.new(code: 'en').locale).to eq :en
    end

    it 'maps rs to :sr' do
      expect(described_class.new(code: 'rs').locale).to eq :sr
    end

    it 'falls back to the default locale for unknown codes' do
      expect(described_class.new(code: 'xx').locale).to eq I18n.default_locale
    end
  end

  describe '#localized' do
    let(:key) { 'common.nobody' }

    context 'when code matches an available locale' do
      let(:country) { described_class.new(code: 'en') }

      it 'translates using that locale' do
        expect(country.localized(key)).to eq I18n.t(key, locale: :en)
      end
    end

    context 'when code is "rs"' do
      let(:country) { described_class.new(code: 'rs') }

      it 'maps to :sr locale' do
        expect(country.localized(key)).to eq I18n.t(key, locale: :sr)
      end
    end

    context 'when code is not an available locale' do
      let(:country) { described_class.new(code: 'xx') }

      it 'falls back to the default locale' do
        expect(country.localized(key)).to eq I18n.t(key, locale: I18n.default_locale)
      end
    end
  end
end
