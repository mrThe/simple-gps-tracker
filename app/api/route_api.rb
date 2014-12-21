module RouteAPI
  class API < Grape::API

    version 'v1', using: :header, vendor: 'device'
    format :json

    helpers do
      # TODO: rewrite
      def current_device
        @current_user ||= User.authorize!(env)
      end

      def authenticate!
        error!('401 Unauthorized', 401) unless current_user
      end
    end

    resource :routes do
      desc "Test."
      get :test do
        { test: true }
      end

      desc "Create a route."
      # params do
      #   requires :id, type: String, desc: "Device ID."
      # end
      post do
        authenticate!
        Status.create!({
          user: current_user,
          text: params[:status]
        })
      end

      desc "Update a status."
      params do
        requires :id, type: String, desc: "Status ID."
        requires :status, type: String, desc: "Your status."
      end
      put ':id' do
        authenticate!
        current_user.statuses.find(params[:id]).update({
          user: current_user,
          text: params[:status]
        })
      end

    end
  end
end