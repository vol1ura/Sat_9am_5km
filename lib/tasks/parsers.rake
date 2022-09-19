# frozen_string_literal: true

namespace :db do
  # rake db:parse_parkrun_codes[kuzminki_db.csv]
  desc 'Add parkrun athletes to database.'
  task :parse_parkrun_codes, [:file_name] => [:environment] do |_, args|
    CSV.foreach("lib/tasks/data/#{args[:file_name]}", headers: true, header_converters: :symbol) do |row|
      barcode = row[:code].delete('A').to_i
      Athlete.find_or_create_by(parkrun_code: barcode) do |athlete|
        athlete.male = row[:gender] == 'M'
        athlete.name = row[:name]
      end
    end
  end

  desc 'unification of athletes names'
  task unify_athletes_names: :environment do
    Athlete.where("name ILIKE ' %' OR name ILIKE '% ' OR name ILIKE '%  %' OR name ILIKE '%\t%'").find_each do |athlete|
      athlete.update(name: athlete.name.gsub(/\s+/, ' ').gsub(/^ | $|(?<= ) /, ''))
    end
  end
end
