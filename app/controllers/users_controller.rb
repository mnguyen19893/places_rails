class UsersController < ApplicationController
  before_action :authorize_request, except: [:create, :login, :index]
  before_action :find_user, except: [:create, :index, :login]

  # POST users/login
  def login
    @user = User.find_by_email(params[:email])
    if @user.present?
      if @user.authenticate(params[:password])
        token = JsonWebToken.encode(user_id: @user.id)
        time = Time.now + 24.hours.to_i
        return render json: {
          status: 'success',
          message: 'You are logged in',
          data: {
            token: token,
            expiration: time.strftime("%m-%d-%Y %H:%M"),
            username: @user.username,
            id: @user.id
          }
        }, status: :ok
      end
    end
    render json: {
      status: 'error',
      message: 'Email or Password is incorrect.'
    }, status: :ok

  end

  def login_params
    params.permit(:email, :password)
  end

  # GET /users
  def index
    @users = User.all.select("id, username, email")
    render json: {
      data: @users
    }, status: :ok
  end

  # GET /{username}
  def show
    render json: @user, status: :ok
  end

  # POST /users
  def create
    @user = User.new(user_params)
    if @user.save
      #UserMailer.welcome_email(@user).deliver_now
      return render json: {
        status: 'success',
        message: 'You are signed up',
        data: {
          username: @user.username,
          email: @user.email
        }
      }, status: :created
    else
      render json: {
        status: 'error',
        message: @user.errors.full_messages.to_s
      }, status: :ok
    end
  end

  # PUT /users/{username}
  def update
    unless @user.update(user_params)
      render json: { errors: @user.errors.full_messages },
             status: :unprocessable_entity
    end
  end

  # DELETE /users/{username}
  def destroy
    @user.destroy
  end

  private

  def find_user
    @user = User.find_by_username(params[:username])
  rescue ActiveRecord::RecordNotFound
    render json: { errors: 'User not found' }, status: :not_found
  end

  def user_params
    params.permit(:username, :email, :password, :password_confirmation)
  end

end
