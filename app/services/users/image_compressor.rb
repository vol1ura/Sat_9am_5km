# frozen_string_literal: true

module Users
  class ImageCompressor < ApplicationService
    MAX_DIMENSION = 300
    MAX_SIZE = 512.kilobytes

    private_constant :MAX_SIZE, :MAX_DIMENSION

    def initialize(user)
      @user = user
    end

    def call
      return unless @user.image.attached?
      return if Vips::Image.new_from_file(image_file.path).size.max <= MAX_DIMENSION && image_file.size <= MAX_SIZE

      compressed_image_file = ImageProcessing::Vips
        .source(image_file)
        .resize_to_fill(MAX_DIMENSION, MAX_DIMENSION)
        .saver(quality: 95, compression: :lzw)
        .call

      if compressed_image_file.size <= MAX_SIZE
        @user.image.attach(io: compressed_image_file, filename: "avatar#{File.extname(compressed_image_file)}")
      else
        @user.image.purge
      end
    ensure
      image_file.close
      image_file.unlink
    end

    private

    def image_file
      return @image_file if @image_file

      @image_file = Tempfile.new
      @image_file.binmode
      @image_file.write(@user.image.download)
      @image_file.rewind
      @image_file
    end
  end
end
