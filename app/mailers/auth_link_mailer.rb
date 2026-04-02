# frozen_string_literal: true

class AuthLinkMailer < ApplicationMailer
  def login_link(user)
    @user = user
    @url = auth_link_url(token: user.auth_token)
    @ttl_minutes = Users::AuthToken::TTL / 1.minute

    mail(to: @user.email, subject: t('.subject'))
  end
end
