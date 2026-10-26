# frozen_string_literal: true

class UserNotificationMailer < ApplicationMailer
  def notify(user, html_body)
    sleep(rand + 0.25) # TODO: remove after mail server is changed
    @html_body = html_body
    @unsubscribe_url = "https://#{user.country&.host || 's95.ru'}/user"

    headers['List-Unsubscribe'] = "<#{@unsubscribe_url}>"
    headers['List-Unsubscribe-Post'] = 'List-Unsubscribe=One-Click'

    I18n.with_locale(user.country&.locale || I18n.default_locale) do
      mail to: email(user), subject: t('.subject')
    end
  end
end
