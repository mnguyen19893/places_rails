class PasswordController < ApplicationController
  def forgot
    if params[:email].blank?
      return render json: { errors: 'Email is invalid' }
    end

    user = User.find_by(email: params[:email])
    if user.present?
      user.generate_password_token
      UserMailer.reset_password(user).deliver_now
      render json: { status: 'ok' }, status: :ok
    else
      render json: { error: 'Email address not found.' }, status: :not_found
    end
  end

  def reset
    token = params[:token]
    if token.blank?
      return render json: { error: 'Token not present'}
    end

    new_password = params[:password]
    if new_password.blank?
      return render json: { error: 'Invalid new password' }
    end

    user = User.find_by(reset_password_token: token)
    if user.present? && user.password_token_valid
      if user.reset_password(params[:password])
        render json: { status: 'ok'}, status: :ok
      else
        render json: { error: user.errors.full_messages }, status: :unprocessable_entity
      end
    else
      render json: { error: 'Link not valid or expired. Try generating a new link'}, status: :not_found
    end

  end
end
