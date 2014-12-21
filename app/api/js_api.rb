module JsAPI
  class API < Grape::API

    version 'v1', using: :header, vendor: 'js'
    format :json

    resource :devices do
      desc "Get routes by device."
      params do
        requires :id, type: String, desc: "Device id."
      end
      get ':id' do
        Device.find(params[:id]).routes
      end
    end
  end
end