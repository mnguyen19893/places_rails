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
    if @place.valid?
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
