# frozen_string_literal: true

# Outputs athlete QR-code in SVG format
class BarcodePrinter < ApplicationService
  OPTIONS = {
    color: '2a2951',
    fill: :white,
    shape_rendering: 'optimizeSpeed',
    module_size: 8,
    offset: 8,
    standalone: true,
    use_path: true,
  }.freeze

  def initialize(athlete)
    @code = "A#{athlete.code}"
  end

  def call
    RQRCode::QRCode.new(@code).as_svg(OPTIONS)
  end
end
