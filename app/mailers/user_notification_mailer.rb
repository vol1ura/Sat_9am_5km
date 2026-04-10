# frozen_string_literal: true

class UserNotificationMailer < ApplicationMailer
  UNSUBSCRIBE_URL = 'https://s95.ru/user'

  def notify(user, html_body)
    sleep(rand + 0.75) # TODO: remove after mail server is changed
    @html_body = html_body
    @unsubscribe_url = UNSUBSCRIBE_URL
    headers['List-Unsubscribe'] = "<#{UNSUBSCRIBE_URL}>"
    headers['List-Unsubscribe-Post'] = 'List-Unsubscribe=One-Click'
    mail(to: user.email, subject: t('.subject'))
  end
end
