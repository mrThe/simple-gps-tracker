class Route
  include Mongoid::Document
  include Mongoid::Geospatial

  field :device_id, type: Integer
  field :route,     type: MongoizedLine, default: []
  field :start_at,  type: Time
  field :end_at,    type: Time
  field :finalized, type: Boolean, default: false

  index({route: '2dsphere'}, background: false)

  validate :device_id, presence: true

  belongs_to :device

  def add_points!(points)
    self.route += points
    self.save!

    self
  end

  def check_alerts(points)
    alerts = device.alerts.geo_spacial(:area.intersects_line => Route.last.route)
    # TODO: log alerts
  end
end
