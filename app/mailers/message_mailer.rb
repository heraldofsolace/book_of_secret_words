class MessageMailer < ApplicationMailer
  # set a sensible default if you haven't already in ApplicationMailer
  default from: "Book of Secret Words <no-reply@bookofsecretwords.example>"

  def new_message_notification(user, message)
    @user    = user
    @message = message

    mail(
      to: @user.email,
      subject: "You received a new secret message"
    )
  end
end
