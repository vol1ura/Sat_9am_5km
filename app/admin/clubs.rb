# frozen_string_literal: true

ActiveAdmin.register Club do
  includes :country, logo_attachment: :blob

  permit_params :name, :country_id, :logo, :description

  actions :all, except: :show

  filter :name
  filter :country

  index download_links: false do
    selectable_column
    id_column
    column(:logo) { |c| image_tag c.logo.variant(resize_to_limit: [60, 60]) if c.logo.attached? }
    column :name
    column :country
    actions
  end

  form do |f|
    f.semantic_errors(*f.object.errors.attribute_names)
    f.inputs do
      f.input :country
      f.input :name
      f.input :description, as: :quill_editor,
                            label: 'Описание',
                            input_html: {
                              data: {
                                options: {
                                  modules: {
                                    toolbar: [
                                      %w[bold italic strike],
                                      %w[blockquote code-block],
                                      [{ list: 'ordered' }, { list: 'bullet' }],
                                      ['link'],
                                      ['clean']
                                    ],
                                  },
                                  placeholder: 'Какой же классный клуб...',
                                  theme: 'snow',
                                },
                              },
                            }
      f.input :logo, as: :file
    end

    f.actions
  end
end
