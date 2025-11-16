# frozen_string_literal: true

class AddNameTranslationsToBadges < ActiveRecord::Migration[8.0]
  def up
    add_column :badges, :name_translations, :jsonb
    Badge.update_all("name_translations = jsonb_build_object('ru', name)")
    remove_column :badges, :name
  end

  def down
    add_column :badges, :name, :text
    Badge.update_all("name = name_translations->>'ru'")
    remove_column :badges, :name_translations
  end
end
