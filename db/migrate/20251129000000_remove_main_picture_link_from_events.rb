# frozen_string_literal: true

class RemoveMainPictureLinkFromEvents < ActiveRecord::Migration[8.0]
  def change
    remove_column :events, :main_picture_link, :string
  end
end
