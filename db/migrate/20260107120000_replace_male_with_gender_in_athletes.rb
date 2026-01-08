# frozen_string_literal: true

class ReplaceMaleWithGenderInAthletes < ActiveRecord::Migration[8.1]
  def up
    create_enum :athlete_gender, %w[male female]
    add_column :athletes, :gender, :athlete_gender

    Athlete.where(male: true).update_all(gender: 'male')
    Athlete.where(male: false).update_all(gender: 'female')

    remove_column :athletes, :male

    Badge
      .where("info->>'male' = 'true'")
      .update_all("info = (info - 'male') || jsonb_build_object('gender', 'male')")
    Badge
      .where("info->>'male' = 'false'")
      .update_all("info = (info - 'male') || jsonb_build_object('gender', 'female')")
  end

  def down
    add_column :athletes, :male, :boolean # rubocop:disable Rails/ThreeStateBooleanColumn

    Athlete.where(gender: 'male').update_all(male: true)
    Athlete.where(gender: 'female').update_all(male: false)

    remove_column :athletes, :gender
    drop_enum :athlete_gender

    Badge
      .where("info->>'gender' = 'male'")
      .update_all("info = (info - 'gender') || jsonb_build_object('male', true)")
    Badge
      .where("info->>'gender' = 'female'")
      .update_all("info = (info - 'gender') || jsonb_build_object('male', false)")
  end
end
