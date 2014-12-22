class MongoizedLine < Mongoid::Geospatial::Line

  def initialize(points)
    @points = points
  end

  # Converts an object of this instance into a database friendly value.
  def mongoize
    if @points.empty?
      []
    else
      {
        type: "LineString",
        coordinates: @points.to_a
      }
    end
  end

  class << self

    # Get the object as it was stored in the database, and instantiate
    # this custom class from it.
    def demongoize(object)
      object[:coordinates] rescue []
    end

    # Takes any possible object and converts it to how it would be
    # stored in the database.
    def mongoize(object)
      case object
      when Array then MongoizedLine.new(object).mongoize
      else object
      end
    end

    # Converts the object that was supplied to a criteria and converts it
    # into a database friendly form.
    def evolve(object)
      case object
      when Array then MongoizedLine.new(object).mongoize
      else object
      end
    end
  end
end