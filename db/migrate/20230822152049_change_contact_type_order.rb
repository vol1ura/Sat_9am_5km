class ChangeContactTypeOrder < ActiveRecord::Migration[7.0]
  def up
    9.downto(1) do |contact_type|
      Contact.where(contact_type: contact_type).update_all(contact_type: contact_type.next)
    end
  end

  def down
    2.upto(10) do |contact_type|
      Contact.where(contact_type: contact_type).update_all(contact_type: contact_type.pred)
    end
  end
end
