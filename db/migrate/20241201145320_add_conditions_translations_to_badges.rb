# frozen_string_literal: true

class AddConditionsTranslationsToBadges < ActiveRecord::Migration[8.0]
  def up
    add_column :badges, :conditions_translations, :jsonb
    Badge.update_all("conditions_translations = jsonb_build_object('ru', conditions)")
    remove_column :badges, :conditions
  end

  def down
    add_column :badges, :conditions, :text
    Badge.update_all("conditions = conditions_translations->>'ru'")
    remove_column :badges, :conditions_translations
  end
end
