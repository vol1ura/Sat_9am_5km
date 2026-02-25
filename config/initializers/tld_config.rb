# frozen_string_literal: true

# Configure allowed top-level domains for the application
# This list is used in ApplicationController#top_level_domain
# do not forget to add a new locale when creating a new domain.
ALLOWED_TLDS = %w[ru rs by kz].freeze
DEFAULT_TLD = :ru