# frozen_string_literal: true

class AddMainPictureLinkToEvents < ActiveRecord::Migration[7.0]
  def change
    add_column :events, :main_picture_link, :string
  end
end
