# frozen_string_literal: true

module Ui
  # In-page section title (h2). Use for major content blocks on a page that
  # already has a unique h1 (PageHeaderComponent or a custom page hero).
  # For centered marketing headings use Ui::SectionHeadingComponent.
  class SectionHeaderComponent < ApplicationComponent
    renders_one :actions

    def initialize(title:, id: nil)
      super()
      @title = title
      @id = id
    end

    erb_template <<~ERB
      <header class="mb-6 flex flex-col gap-4 sm:flex-row sm:items-start sm:justify-between">
        <%= tag.h2 @title, id: @id, class: 'font-display text-xl font-semibold text-ink sm:text-2xl' %>
        <% if actions? %>
          <div class="flex shrink-0 flex-wrap gap-2"><%= actions %></div>
        <% end %>
      </header>
    ERB
  end
end
