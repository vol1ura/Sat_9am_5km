# frozen_string_literal: true

module Ui
  class EmptyComponent < ApplicationComponent
    def initialize(title:, description: nil)
      super()
      @title = title
      @description = description
    end

    erb_template <<~ERB
      <div class="flex flex-col items-center justify-center rounded-lg border border-dashed border-line bg-surface px-6 py-12 text-center">
        <i class="fa-solid fa-inbox mb-4 text-3xl text-ink-muted" aria-hidden="true"></i>
        <h2 class="font-display text-lg font-semibold text-ink"><%= @title %></h2>
        <% if @description.present? %>
          <p class="mt-2 max-w-sm text-sm text-ink-muted"><%= @description %></p>
        <% end %>
        <% if content? %>
          <div class="mt-4"><%= content %></div>
        <% end %>
      </div>
    ERB
  end
end
