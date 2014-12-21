class Device
  include MongoMapper::Document

  key :name, String
  key :api_key, String

end
