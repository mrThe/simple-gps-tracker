class AlertNotificationMailer < ActionMailer::Base
  default from: "from@example.com"

  def notify(alert_notification)
    @alert_notification = alert_notification
    mail(to: alert_notification.alert.emails, subject: "Route Alert!")
  end
end
