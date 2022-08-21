# frozen_string_literal: true

require 'barby'
require 'barby/barcode/code_128'
require 'barby/outputter/svg_outputter'

# Outputs athlete parkrun barcode in SVG format
class BarcodePrinter < ApplicationService
  def initialize(athlete)
    @code = "A#{athlete.code}"
    @barcode = Barby::Code128.new(@code)
  end

  def call
    outputter.xdim = 2
    outputter.title = @code
    outputter.to_svg
  end

  private

  def outputter
    @outputter ||= Barby::SvgOutputter.new(@barcode)
  end
end
