class RemoveColumnPictureLinkFromBadges < ActiveRecord::Migration[7.1]
  def up
    Badge.find_each do |badge|
      badge.image.attach(
        io: File.open(File.join('app/assets/images', badge.picture_link)),
        filename: badge.picture_link.sub('badges/', ''),
      )
      badge.save!
    end

    remove_column :badges, :picture_link
  end

  def down
    add_column :badges, :picture_link, :string

    Badge.find_each do |badge|
      badge.update!(picture_link: "badges/#{badge.image_attachment.filename}")
      badge.image.purge
    end
  end
end
