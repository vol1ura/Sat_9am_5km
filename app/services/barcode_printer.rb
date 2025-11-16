# frozen_string_literal: true

# Outputs QR-code in SVG format
class BarcodePrinter < ApplicationService
  OPTIONS = {
    color: '2a2951',
    fill: :white,
    shape_rendering: 'optimizeSpeed',
    offset: 8,
    standalone: true,
    use_path: true,
  }.freeze

  def initialize(code, module_size:)
    @code = code
    @module_size = module_size
  end

  def call
    RQRCode::QRCode.new(@code).as_svg(OPTIONS.merge(module_size: @module_size)).html_safe # rubocop:disable Rails/OutputSafety
  end
end
