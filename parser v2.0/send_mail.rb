require 'io/console'
require 'pony'

class SendMail
  attr_reader :user, :receiver, :body

  def initialize(user, receiver, body)
      @user = user
      @receiver = receiver
      @body = body
  end

  def send_mail
    Pony.mail({
      :subject => "Прийшов архів з парсером",
      :body => body,
      :to => receiver,
      :from => user.login,
      :attachments => {File.basename('parser.zip') => File.read('parser.zip')},
      :via => :smtp,
      :via_options => {
        :address => 'smtp.gmail.com',
        :port => '465',
        :tls => true,
        :user_name => user.login,
        :password => user.password,
        :authentication => :plain
      }
    })
  end
end
