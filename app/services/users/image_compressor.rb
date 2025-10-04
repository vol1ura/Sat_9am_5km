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

      download_image_file
      return unless @image_file
      return if Vips::Image.new_from_file(@image_file.path).size.max <= MAX_DIMENSION && @image_file.size <= MAX_SIZE

      compressed_image_file = ImageProcessing::Vips
        .source(@image_file)
        .resize_to_fill(MAX_DIMENSION, MAX_DIMENSION)
        .saver(quality: 95, compression: :lzw)
        .call

      if compressed_image_file.size <= MAX_SIZE
        @user.image.attach(io: compressed_image_file, filename: "avatar#{File.extname(compressed_image_file)}")
      else
        @user.image.purge
      end
    ensure
      cleanup_temp_file
    end

    private

    def download_image_file
      return if @image_file

      @image_file = Tempfile.new
      @image_file.binmode
      @image_file.write(@user.image.download)
      @image_file.rewind
    rescue ActiveStorage::FileNotFoundError => e
      Rails.logger.warn("Failed to download image for user #{@user.id}: #{e.message}")
      cleanup_temp_file
      @image_file = nil
    end

    def cleanup_temp_file
      @image_file&.close
      @image_file&.unlink
    end
  end
end
