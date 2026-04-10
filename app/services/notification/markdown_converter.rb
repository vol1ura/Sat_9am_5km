# frozen_string_literal: true

module Notification
  module MarkdownConverter
    RULES = [
      [/\*(.+?)\*/m,         '<strong>\1</strong>'],
      [/_(.+?)_/m,           '<em>\1</em>'],
      [/`(.+?)`/m,           '<code>\1</code>'],
      [/\[(.+?)\]\((.+?)\)/, '<a href="\2">\1</a>'],
    ].freeze

    def self.to_html(text)
      RULES.reduce(text) { |str, (pattern, replacement)| str.gsub(pattern, replacement) }.gsub "\n", '<br>'
    end
  end
end
