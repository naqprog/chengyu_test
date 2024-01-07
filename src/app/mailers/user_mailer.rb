class UserMailer < ApplicationMailer
  def welcome_email(user)
    @email = user[:email]
    @url  = 'http://chengyu-test.com/'
    mail(to: @email, subject: '「成語テスト」にようこそ！')
  end
end
