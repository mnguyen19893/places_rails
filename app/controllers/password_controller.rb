class PasswordController < ApplicationController

  # POST '/users/forgot'
  def forgot
    if params[:email].blank?
      return render json: {
        status: 'error',
        message: 'Email is not valid.'
      }, status: :ok
    end

    user = User.find_by_email(params[:email])
    if user.present?
      user.generate_password_token
      UserMailer.reset_password(user).deliver_now
      render json: {
        status: 'success',
        message: 'We sent a token to your email. Please check it!',
      }, status: :ok
    else
      render json: {
        status: 'error',
        message: 'Email address not found.'
      }, status: :ok
    end
  end

  # POST '/password/reset'
  def reset
    token = params[:token]
    if token.blank?
      return render json: {
        status: 'error',
        message: 'Token cannot be blank.'
      }, status: :ok
    end

    new_password = params[:password]
    if new_password.blank?
      return render json: {
        status: 'error',
        message: 'Invalid new password.'
      }, status: :ok
    end

    user = User.find_by(reset_password_token: token)
    if user.present? && user.password_token_valid
      if user.reset_password(params[:password])
        render json: {
          status: 'success',
          message: 'Successfully update your password'
        }, status: :ok
      else
        return render json: {
          status: 'error',
          message: user.errors.full_messages.to_s
        }, status: :ok
      end
    else
      render json: {
        status: 'error',
        message: 'Link not valid or expired. Try generating a new link'
      }, status: :ok
    end
  end
end
