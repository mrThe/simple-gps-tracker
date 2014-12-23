class Route
  include Mongoid::Document
  include Mongoid::Geospatial

  field :device_id, type: Integer
  field :route,     type: MongoizedLine, default: []
  field :start_at,  type: Time
  field :end_at,    type: Time
  field :finalized, type: Boolean, default: false

  index({route: '2dsphere'}, background: true)

  validates :device_id, presence: true

  belongs_to :device
  has_many :alert_notifications

  def add_points!(points)
    self.route += points
    self.save!

    self
  end

  def check_alerts(points)
    alerts = device.alerts.geo_spacial(:area.intersects_line => points)
    alerts.each do |alert|
      alert_notifications.create alert: alert, device: self.device, alerted_at: Time.now
    end
  end
end
