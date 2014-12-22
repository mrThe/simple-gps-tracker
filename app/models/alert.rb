class Alert
  include Mongoid::Document
  include Mongoid::Geospatial

  field :area,      type: MongoizedPolygon
  field :device_id, type: Integer
  field :emails,    type: Array

  index({area: '2dsphere'}, background: false)

  validate :device_id, :area, presence: true

  belongs_to :device

  before_validation :close_polygon

  private

  def close_polygon
    # Google maps don't close polygons by default
    self.area += [area.first] if area.last != area.first
  end
end

