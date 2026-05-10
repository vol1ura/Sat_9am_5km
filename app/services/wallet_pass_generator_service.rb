# frozen_string_literal: true

class WalletPassGeneratorService < ApplicationService
  PASS_DIR = Rails.root.join('config/wallet_pass')

  IMAGE_FILES = %w[icon.png icon@2x.png icon@3x.png logo.png logo@2x.png strip.png strip@2x.png].freeze

  param :athlete_code, ->(v) { normalize_code(v) }, reader: :private
  option :athlete_name, reader: :private, default: -> { '' }
  option :emergency_contact_name, reader: :private, default: -> { '' }
  option :emergency_contact_phone, reader: :private, default: -> { '' }
  option :home_event_name, reader: :private, default: -> { '' }
  option :runs_count, reader: :private, default: -> { 0 }
  option :volunteering_count, reader: :private, default: -> { 0 }

  option :latitude, reader: :private, default: -> { nil }
  option :longitude, reader: :private, default: -> { nil }
  option :relevant_date, reader: :private, default: -> { nil }

  def self.normalize_code(code)
    code = code.to_s.strip
    code.match?(/^A\d+$/i) ? code.upcase : "A#{code}"
  end

  def call
    validate_assets!

    files = {}
    files['pass.json'] = pass_json.to_json
    collect_images(files)
    files['manifest.json'] = build_manifest(files).to_json
    sign_manifest(files)

    build_zip(files)
  rescue StandardError => e
    Rails.logger.error "WalletPassGeneratorService error: #{e.message}"
    raise
  end

  private

  def validate_assets!
    has_p12 = File.exist?(PASS_DIR.join('pass.p12'))
    has_raw = File.exist?(PASS_DIR.join('pass.cer')) && File.exist?(PASS_DIR.join('pass.key'))

    raise "Missing pass.p12 or pass.cer/key in #{PASS_DIR}" unless has_p12 || has_raw
    raise "Missing AppleWWDRCAG4.cer in #{PASS_DIR}" unless File.exist?(PASS_DIR.join('AppleWWDRCAG4.cer'))
  end

  def pass_json
    subject = certificate.subject.to_a
    json = {
      formatVersion: 1,
      passTypeIdentifier: subject.find { |e| e[0] == 'UID' }&.dig(1),
      teamIdentifier: subject.find { |e| e[0] == 'OU' }&.dig(1),
      serialNumber: "s95-#{athlete_code}-#{Digest::MD5.hexdigest(athlete_code)[0, 8]}",
      organizationName: 'S95',
      description: I18n.t('wallet_passes.new.description'),
      foregroundColor: 'rgb(255, 255, 255)',
      backgroundColor: 'rgb(42, 41, 81)',
      labelColor: 'rgb(158, 190, 190)',
      generic: {
        headerFields: [
          { key: 'logo_text', label: '', value: 'С95' },
        ],
        primaryFields: [
          { key: 'name', label: I18n.t('wallet_passes.new.athlete_label').upcase, value: athlete_name.presence || I18n.t('wallet_passes.new.default_athlete_name') },
        ],
        secondaryFields: [
          { key: 'runs', label: I18n.t('athletes.show.results').upcase, value: runs_count.to_s },
          { key: 'vols', label: I18n.t('athletes.show.volunteering').upcase, value: volunteering_count.to_s },
          { key: 'id', label: 'ID', value: athlete_code },
        ],
        auxiliaryFields: [
          { key: 'home', label: I18n.t('activerecord.attributes.athlete.event').upcase, value: home_event_name.presence || '—' },
        ],
        backFields: back_fields,
      },
      barcodes: [
        { message: athlete_code, format: 'PKBarcodeFormatQR', messageEncoding: 'iso-8859-1' },
        { message: athlete_code, format: 'PKBarcodeFormatCode128', messageEncoding: 'iso-8859-1' },
      ],
    }

    if latitude && longitude
      json[:locations] = [
        {
          latitude: latitude.to_f,
          longitude: longitude.to_f,
          relevantText: I18n.t('wallet_passes.new.location_relevant_text')
        }
      ]
    end

    json[:relevantDate] = relevant_date.iso8601 if relevant_date

    if ENV['APPLE_WALLET_WEB_SERVICE_URL'].present?
      json[:webServiceURL] = ENV['APPLE_WALLET_WEB_SERVICE_URL']
      registration = WalletPassRegistration.find_by(serial_number: json[:serialNumber])
      json[:authenticationToken] = registration&.auth_token || Digest::SHA256.hexdigest(athlete_code + Rails.application.secret_key_base)[0...20]
    end

    json
  end

  def back_fields
    fields = []
    fields << { key: 'emergency_name', label: I18n.t('wallet_passes.new.emergency_contact'), value: emergency_contact_name } if emergency_contact_name.present?
    fields << { key: 'emergency_phone', label: I18n.t('wallet_passes.new.emergency_contact_phone'), value: emergency_contact_phone } if emergency_contact_phone.present?
    fields << { key: 'info', label: I18n.t('wallet_passes.new.how_it_works_title'), value: I18n.t('wallet_passes.new.step_4') }
    fields << { key: 'website', label: I18n.t('navbars.about_s95.about'), value: 'https://s95.ru' }
    fields
  end

  def collect_images(files)
    @cached_images ||= IMAGE_FILES.each_with_object({}) do |filename, memo|
      path = PASS_DIR.join(filename)
      memo[filename] = File.binread(path) if File.exist?(path)
    end
    files.merge!(@cached_images)
  end

  def build_manifest(files)
    files.transform_values { |content| Digest::SHA1.hexdigest(content) }
  end

  def sign_manifest(files)
    @cached_wwdr ||= OpenSSL::X509::Certificate.new(File.binread(PASS_DIR.join('AppleWWDRCAG4.cer')))

    signature = OpenSSL::PKCS7.sign(
      certificate,
      private_key,
      files['manifest.json'],
      [@cached_wwdr],
      OpenSSL::PKCS7::BINARY | OpenSSL::PKCS7::DETACHED,
    )

    files['signature'] = signature.to_der
  end

  def build_zip(files)
    buffer = Zip::OutputStream.write_buffer do |zip|
      files.each do |name, content|
        zip.put_next_entry(name)
        zip.write(content)
      end
    end
    buffer.string
  end

  def p12
    @p12 ||= if File.exist?(PASS_DIR.join('pass.p12'))
               OpenSSL::PKCS12.new(
                 File.binread(PASS_DIR.join('pass.p12')),
                 Rails.application.credentials.dig(:apple_wallet, :certificate_password) || '',
               )
             end
  rescue OpenSSL::PKCS12::PKCS12Error => e
    Rails.logger.warn "WalletPassGeneratorService: Failed to load P12: #{e.message}. Trying raw files..."
    nil
  end

  def certificate
    @certificate ||= p12&.certificate || OpenSSL::X509::Certificate.new(File.read(PASS_DIR.join('pass.cer')))
  end

  def private_key
    @private_key ||= p12&.key || OpenSSL::PKey::RSA.new(File.read(PASS_DIR.join('pass.key')))
  end
end
