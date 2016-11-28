class Notification < ApplicationRecord
  belongs_to :user

  scope :unread, -> { where(read: false) }

  after_create :trigger_sms

  def trigger_sms
    if user.loans.last.status == "Application Accepted"
      sms_message = "Congratulations! Your loan has been accepted.
                     "
    elsif user.loans.last.status == "Application Declined"
      sms_message = "We are sorry to inform you that your loan application has
                       been declined. Please visit the Manda website for more details"
    end
    send_text_notification(user.mobile_number, sms_message)
  end

  private

  def send_text_notification(mobile_number, sms_message)
    twilio_number = ENV['TWILIO_NUMBER']
    client = Twilio::REST::Client.new(ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN'])

    client.messages.create(
      from: twilio_number,
      to: mobile_number,
      body: sms_message)
  end
end
