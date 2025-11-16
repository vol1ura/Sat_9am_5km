# frozen_string_literal: true

class AddCountryCodeToEvent < ActiveRecord::Migration[7.0]
  def up
    create_enum :country_code, %w[ru by rs]
    add_column :events, :country_code, :country_code, null: false, default: 'ru'
  end

  def down
    remove_column :events, :country_code
    execute <<-SQL.squish
      DROP TYPE country_code;
    SQL
  end
end
