# frozen_string_literal: true

class OptimizeActiveStorageAttachmentsIndex < ActiveRecord::Migration[7.2]
  def change
    remove_index(
      :active_storage_attachments,
      %i[record_type record_id name blob_id],
      name: :index_active_storage_attachments_uniqueness,
      unique: true,
    )
    add_index(
      :active_storage_attachments,
      %i[record_id record_type name blob_id],
      name: :index_active_storage_attachments_uniqueness,
      unique: true,
    )
  end
end
