class CreateNewsletters < ActiveRecord::Migration[7.1]
  def change
    create_table :newsletters do |t|
      t.text :body, null: false
      t.string :picture_link

      t.timestamps
    end
  end
end
