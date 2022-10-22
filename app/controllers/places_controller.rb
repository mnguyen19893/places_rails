class PlacesController < ApplicationController
  def index
    #@places = Place.includes(:user, :type).all
    # @places = Place.all
    # @places = Place.joins(:type)
    #                .select("places.*, types.name as type")
    # @places = Place.includes(:type).select("*")
    @places = Place.select("places.*, types.name as type_name, users.username as author").joins(:type).joins(:user)

    render json: {
      status: 'success',
      data: @places
    }, status: :ok
  end

  def show
  end
end
