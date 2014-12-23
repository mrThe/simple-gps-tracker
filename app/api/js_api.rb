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
        Device.find(params[:id]).routes.as_json(include: {alert_notifications: { include: :alert }})
      end
    end

    resource :alerts do
      desc "Get alerts by device."
      params do
        requires :device_id, type: String, desc: "Device id."
      end
      get do
        Device.find(params[:device_id]).alerts
      end

      desc "Create an alert."
      params do
        requires :name, type: String, desc: "Alert name"
        requires :area, type: Array[Array], desc: "Polygon points"
        requires :device_id, type: String, desc: "Device id."
        requires :emails, type: Array, desc: "Emails array."
      end
      post do
        Alert.create!({
          name:      params[:name],
          area:      params[:area].map(&:second).map{|a| a.map &:to_f }, # Grape, WTF? Fuck it params parser.
          device_id: params[:device_id],
          emails:    params[:emails]
        }).as_json(only: :id)
      end

    end
  end
end