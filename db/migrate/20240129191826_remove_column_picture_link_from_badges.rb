# frozen_string_literal: true

class RemoveColumnPictureLinkFromBadges < ActiveRecord::Migration[7.1]
  def up
    remove_column :badges, :picture_link
  end

  def down
    add_column :badges, :picture_link, :string
  end
end
