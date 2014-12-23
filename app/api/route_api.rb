module RouteAPI
  class API < Grape::API

    version 'v1', using: :header, vendor: 'device'
    format :json

    helpers do
      def current_device
        @current_device ||= Device.find_by api_key: params[:token] rescue nil
      end

      def authenticate!
        error!('401 Unauthorized', 401) unless current_device
      end
    end

    resource :routes do
      desc "Create a route."
      params do
        requires :start_at, type: Time, desc: "Start time."
      end
      post do
        authenticate!
        Route.create!({
          device: current_device,
          start_at: params[:start_at]
        }).as_json(only: :id)
      end

      desc "Add bunch of points to the route."
      params do
        requires :id, type: String, desc: "Route ID."
        requires :points, type: Array, desc: "New bunch of points." do
          requires :lat, type: Float
          requires :lng, type: Float
        end
      end
      put ':id' do
        authenticate!
        current_route = current_device.routes.find(params[:id])
        error! 'Route already finalized!', 410 if current_route.finalized?

        points = params[:points].map(&:values)
        current_route.add_points! points
        current_route.check_alerts points

        current_route.as_json(only: :id)
      end

      desc "Finalize route."
      params do
        requires :id, type: String, desc: "Route ID."
        requires :end_at, type: Time, desc: "End time."
      end
      put ':id/finalize' do
        authenticate!
        current_route = current_device.routes.find(params[:id])
        error! 'Route already finalized!', 410 if current_route.finalized?

        current_route.end_at = params[:end_at]
        current_route.finalized = true
        current_route.save!
      end

    end
  end
end