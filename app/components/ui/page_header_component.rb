# frozen_string_literal: true

module Ui
  class PageHeaderComponent < ApplicationComponent
    renders_one :actions

    def initialize(title:, description: nil)
      super()
      @title = title
      @description = description
    end

    erb_template <<~ERB
      <header class="mb-6 flex flex-col gap-4 sm:flex-row sm:items-start sm:justify-between">
        <div>
          <h1 class="font-display text-2xl font-bold text-ink sm:text-3xl"><%= @title %></h1>
          <% if @description.present? %>
            <div class="mt-2 space-y-2 text-ink-muted"><%= @description %></div>
          <% end %>
        </div>
        <% if actions? %>
          <div class="flex shrink-0 flex-wrap gap-2"><%= actions %></div>
        <% end %>
      </header>
    ERB
  end
end
