class Route
  include Mongoid::Document
  include Mongoid::Geospatial

  field :device_id, type: Integer
  field :route,     type: Line, default: []
  field :start_at,  type: Time
  field :end_at,    type: Time
  field :finalized, type: Boolean, default: false

  spatial_index :route
  validate :device_id, presence: true

  belongs_to :device
end
