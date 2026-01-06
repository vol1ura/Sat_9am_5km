# frozen_string_literal: true

# Outputs QR-code in SVG format
class BarcodeService < ApplicationService
  OPTIONS = {
    color: '2a2951',
    fill: :white,
    shape_rendering: 'optimizeSpeed',
    offset: 8,
    standalone: true,
    use_path: true,
  }.freeze

  param :code, reader: :private
  option :module_size, reader: :private

  def call
    RQRCode::QRCode.new(code).as_svg(OPTIONS.merge(module_size:)).html_safe # rubocop:disable Rails/OutputSafety
  end
end
