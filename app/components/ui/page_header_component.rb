# frozen_string_literal: true

module Ui
  # Unique page title (h1). Render at most once per page.
  # For in-page section titles use Ui::SectionHeaderComponent.
  class PageHeaderComponent < ApplicationComponent
    renders_one :actions

    def initialize(title:, description: nil, variant: :default)
      super()
      @title = title
      @description = description
      @variant = variant.to_sym
    end

    def title_class
      [
        'font-display text-2xl font-semibold text-ink sm:text-3xl',
        ('border-l-4 border-accent pl-4' if @variant == :rule),
      ].compact.join(' ')
    end

    erb_template <<~ERB
      <header class="mb-6 flex flex-col gap-4 sm:flex-row sm:items-start sm:justify-between">
        <div>
          <h1 class="<%= title_class %>"><%= @title %></h1>
          <% if @description.present? %>
            <div class="mt-2 space-y-2 text-ink-muted <%= 'pl-4' if @variant == :rule %>"><%= @description %></div>
          <% end %>
        </div>
        <% if actions? %>
          <div class="flex shrink-0 flex-wrap gap-2"><%= actions %></div>
        <% end %>
      </header>
    ERB
  end
end
