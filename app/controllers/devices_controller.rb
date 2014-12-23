class DevicesController < ApplicationController
  before_action :set_device, only: [:show, :edit, :update, :destroy]

  def index
    @devices = Device.all
  end

  def show
    @map_center = @device.routes.last.route.center rescue [48.476639, 35.056490]
    @alert_notifications = @device.alert_notifications
    if params[:date_to] && params[:date_from]
      @alert_notifications = @alert_notifications.where(:alerted_at.gt => params[:date_from],
                                                        :alerted_at.lte => params[:date_to])
    end
  end

  def new
    @device = Device.new
  end

  def edit
  end

  def create
    @device = Device.new(device_params)

    if @device.save
      redirect_to @device, notice: 'Device was successfully created.'
    else
      render :new
    end
  end

  def update
    if @device.update_attributes(device_params)
      redirect_to @device, notice: 'Device was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @device.destroy
    redirect_to devices_url, notice: 'Device was successfully destroyed.'
  end

  private
    def set_device
      @device = Device.find(params[:id])
    end

    def device_params
      params.require(:device).permit(:name)
    end
end
