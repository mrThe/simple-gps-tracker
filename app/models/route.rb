class Route
  include Mongoid::Document
  include Mongoid::Geospatial

  field :device_id, type: Integer
  field :start_at, type: Time
  field :end_at, type: Time

  field :route, type: Line
end
