require 'fcm'

class PlacesController < ApplicationController
  before_action :authorize_request, except: [:index, :show]

  def get_type
    @types = Type.all
    render json: {
      status: 'success',
      data: @types,

    }, status: :ok
  end

  def mine
    user_id = @current_user.id
    @places = Place.where("user_id = ?", user_id).select("places.*, types.name as type_name, users.username as author").joins(:type).joins(:user)

    render json: {
      status: 'success',
      data: @places,

    }, status: :ok
  end

  def index
    #@places = Place.includes(:user, :type).all
    # @places = Place.all
    # @places = Place.joins(:type)
    #                .select("places.*, types.name as type")
    # @places = Place.includes(:type).select("*")
    @places = Place.select("places.*, types.name as type_name, users.username as author").joins(:type).joins(:user).order("id DESC")

    render json: {
      status: 'success',
      data: @places,

    }, status: :ok
  end

  def show
    @place = Place.select("places.*, types.name as type_name, users.username as author").joins(:type).joins(:user).find(params[:id])

    #@place = Place.select("places.*").joins(:user_places).find(params[:id])

    render json: {
      status: 'success',
      data: {
        place: @place,
        likes: @place.users.select("users.id, users.username, users.email")
      }
    }, status: :ok
  end

  def like
    place_id = params[:id]
    user_id = @current_user.id

    user_place = UserPlace.where("user_id = ? AND place_id = ?", user_id, place_id)
    if user_place.count > 0
      user_place[0].destroy
      render json: {
        status: 'success',
        message: "Successfully unlike",
        data: {
          action: "unlike",
          user: {
            id: @current_user.id,
            username: @current_user.username,
            email: @current_user.email
          }
        }
      }, status: :ok
    else
      # send a notification to the author
      fcm = FCM.new("AAAAbmjZ818:APA91bEu7FLOJ7y4d5sa3uGdYcu4rSI7J1tSjVBjkbNC2aYUlfFVc8D8GavkNVN5Pt07UDPN6prXKDwuZKZ2ZFEcR_uKMaxasybffnfO5hlNmappyjHzQdbban4pfI1JIZRnF_xMQG-e")
      current_username = @current_user.username
      #puts "Current user_name: #{current_username}"

      place = Place.find(place_id)
      #puts "Place_id #{place.id}, author_id: #{place.user_id}"

      author_id = place.user_id
      #puts "author_id: #{author_id}"

      device_infos = DeviceInfo.where("user_id = ?", author_id)

      device_infos.each do |device_info|
        #puts "device_info #{device_info}"
        #puts "Token: #{device_info.token}"
        registration_ids= [device_info.token] # an array of one or more client registration tokens

        # See https://firebase.google.com/docs/cloud-messaging/http-server-ref for all available options.
        options = { "notification": {
          "title": "'#{current_username}' likes your post '#{place.name}'",
          "sound": "default"
          }
        }
        response = fcm.send(registration_ids, options)
      end



      UserPlace.create(user_id: user_id, place_id: place_id)
      render json: {
        status: 'success',
        message: "Successfully like",
        data: {
          action: "like",
          user: {
            id: @current_user.id,
            username: @current_user.username,
            email: @current_user.email
          }
        }
      }, status: :ok
    end
  end

  # Get all places are liked by the current user
  def liked
    #puts "Hoang: #{@current_user.email}"
    @places = []
    @current_user.user_places.each do |up|
      @places << up.place
    end


    render json: {
      status: 'success',
      data: @places,

    }, status: :ok

  end

  def create
    decoded_data = Base64.decode64(params[:image])
    @place = Place.create(
      name: params[:name],
      latitude: params[:latitude],
      longitude: params[:longitude],
      build_in_year: params[:build_in_year],
      location: params[:location],
      type_id: params[:type_id],
      user_id: @current_user.id,
      image: {
        io: StringIO.new(decoded_data),
        content_type: 'image/jpeg',
        filename: 'image.jpg'
      }
    )
    @place.picture_link = url_for(@place.image)

    if @place.save
      render json: {
        status: 'success',
        message: "Successfully create a new place",
      }, status: :ok
    else
      render json: {
        status: 'error',
        message: @place.errors.full_messages.to_s
      }, status: :ok
    end
  end

  def destroy
    @place = Place.find(params[:id])
    if @place.valid? && @place.user_id == @current_user.id
      @place.user_places.destroy_all
      @place.destroy
      render json: {
        status: 'success',
        message: "Successfully delete the place",
      }, status: :ok
    else
      render json: {
        status: 'error',
        message: "Cannot delete the place",
      }, status: :ok
    end
  end

  def update
    @place = Place.find(params[:id])
    if @place.valid?

      decoded_data = Base64.decode64(params[:image])
      @place.name = params[:name]
      @place.latitude = params[:latitude]
      @place.longitude = params[:longitude]
      @place.build_in_year = params[:build_in_year]
      @place.location = params[:location]
      @place.type_id = params[:type_id]
      @place.image.attach(
        io: StringIO.new(decoded_data),
        content_type: 'image/jpeg',
        filename: 'image.jpg'
      )

      if @place.save
        @place.picture_link = url_for(@place.image)
        @place.save
        render json: {
          status: 'success',
          message: "Successfully update a new place",
        }, status: :ok
      else
        render json: {
          status: 'success',
          message: "Successfully create a new place",
        }, status: :ok
      end

    else
      render json: {
        status: 'error',
        message: "Cannot find the place"
      }, status: :ok
    end
  end

  private
  def place_params
    params.permit(:name, :latitude, :longitude, :image, :build_in_year, :location, :type_id)
  end
end
