# frozen_string_literal: true

module Ui
  class CardMetricHeaderComponent < ApplicationComponent
    def initialize(title:, value: nil, increment: nil, icon: nil, heading: :h3)
      super()
      @title = title
      @value = value
      @increment = increment
      @icon = icon
      @heading = heading
    end

    erb_template <<~ERB
      <div class="mb-3 flex items-center justify-between gap-3">
        <%= content_tag @heading, class: 'flex min-w-0 items-center gap-2 font-display font-semibold text-ink' do %>
          <% if @icon.present? %>
            <i class="fa-solid fa-<%= @icon %> text-brand" aria-hidden="true"></i>
          <% end %>
          <span class="truncate"><%= @title %></span>
        <% end %>
        <% if !@value.nil? %>
          <div class="flex shrink-0 items-center gap-2">
            <span class="font-display font-semibold tabular-nums text-ink"><%= @value %></span>
            <% if @increment.present? %>
              <%= render Ui::BadgeComponent.new(variant: :success, label: @increment) %>
            <% end %>
          </div>
        <% end %>
      </div>
    ERB
  end
end
