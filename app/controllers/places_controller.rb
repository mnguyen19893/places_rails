class PlacesController < ApplicationController
  before_action :authorize_request
  def index
    #@places = Place.includes(:user, :type).all
    # @places = Place.all
    # @places = Place.joins(:type)
    #                .select("places.*, types.name as type")
    # @places = Place.includes(:type).select("*")
    @places = Place.select("places.*, types.name as type_name, users.username as author").joins(:type).joins(:user)

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
end
