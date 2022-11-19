class DeviceInfoController < ApplicationController
  before_action :authorize_request
  def create
    user_id = @current_user.id
    token = params[:token]
    device_type = params[:device_type]

    device = DeviceInfo
               .where("user_id = ?", user_id)
               .where("device_type = ?", device_type)
               .where("token = ?", token).first
    puts "Before Device: #{device}"
    if device == nil
      device = DeviceInfo.create(
        token: token,
        device_type: device_type,
        user_id: user_id
      )
    end
    puts "After Device: #{device}"

    render json: {
      status: 'success',
      message: 'Added the token',
      data: device,
    }, status: :ok
  end
end
