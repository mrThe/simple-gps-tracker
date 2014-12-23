class AlertNotification
  include Mongoid::Document

  field :alert_id,   type: Integer
  field :route_id,   type: Integer
  field :device_id,  type: Integer
  field :alerted_at, type: Time

  belongs_to :route
  belongs_to :alert
  belongs_to :device

  after_create :notify

  private

  def notify
     AlertNotificationMailer.notify(self).deliver # Use rails 4.2 for deliver_later
  end
end
