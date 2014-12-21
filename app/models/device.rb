class Device
  include Mongoid::Document

  field :name, type: String
  field :api_key, type: String, default: proc { SecureRandom.hex(16) }

  has_many :routes
end
