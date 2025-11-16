# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy.
# See the Securing Rails Applications Guide for more information:
# https://guides.rubyonrails.org/security.html#content-security-policy-header

# Rails.application.configure do
#   config.content_security_policy do |policy|
#     policy.default_src :self, :https
#     policy.font_src    :self, :https, :data
#     policy.img_src     :self, :https, :data
#     policy.object_src  :none
#     policy.script_src  :self, :https
#     policy.style_src   :self, :https
#     # Specify URI for violation reports
#     # policy.report_uri "/csp-violation-report-endpoint"
#   end
#
#   # Generate session nonces for permitted importmap, inline scripts, and inline styles.
#   config.content_security_policy_nonce_generator = ->(request) { request.session.id.to_s }
#   config.content_security_policy_nonce_directives = %w(script-src style-src)
#
#   # Report violations without enforcing the policy.
#   # config.content_security_policy_report_only = true
# end

# Notes for Arctic Admin and admin assets (uncomment / adapt when enabling CSP):
# If you enable a Content Security Policy in production, ensure the following
# allowances are made for admin pages so remote assets (Sortable/Quill CDN) and
# icon fonts are permitted. Keep these as conservative additions, and prefer
# self-hosting the assets in production where possible.
#
#   config.content_security_policy do |policy|
#     policy.default_src :self, :https
#     # allow JS from jsdelivr (Sortable) and cdn.quilljs if used via CDN
#     policy.script_src  :self, :https, 'https://cdn.jsdelivr.net', 'https://cdn.quilljs.com'
#     # allow styles from the same hosts and inline styles for Quill nonces if necessary
#     policy.style_src   :self, :https, 'https://cdn.jsdelivr.net', 'https://cdn.quilljs.com', :unsafe_inline
#     # fonts must be allowed from self, data, and your asset host
#     policy.font_src    :self, :https, :data
#     policy.img_src     :self, :https, :data
#   end
#
# Note: If you self-host Quill and Sortable (recommended) you can avoid adding
# external hosts and keep a tighter policy by serving those files from your
# asset pipeline (precompile) and referencing them locally.

