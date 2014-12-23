class Alert
  include Mongoid::Document
  include Mongoid::Geospatial

  field :name,      type: String
  field :area,      type: MongoizedPolygon
  field :device_id, type: Integer
  field :emails,    type: Array

  index({area: '2dsphere'}, background: true)

  validates :device_id, presence: true

  belongs_to :device
  has_many :alert_notifications

  before_validation :close_polygon

  private

  def close_polygon
    # Google maps don't close polygons by default
    self.area += [area.first] if area.last != area.first
  end
end

