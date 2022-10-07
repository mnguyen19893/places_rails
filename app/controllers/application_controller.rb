class ApplicationController < ActionController::API
  def not_found
    render json: { error: 'not_found'}
  end

  # has responsibility for authorizing user requests. We need to get a token in the header with 'Authorization' as a key
  # with this token now we can decode and get the payload value.
  # You should not include the user credentials data into the payload because it will cause security issues,
  def authorize_request
    header = request.headers['Authorization']
    header = header.split(' ').last if header
    begin
      @decoded = JsonWebToken.decode(header)
      @current_user = User.find(@decoded[:user_id])
    rescue ActiveRecord::RecordNotFound => e
      render json: { errors: e.message}, status: :unauthorized
    rescue JWT::DecodeError => e
      render json: { errors: e.message}, status: :unauthorized
    end
  end

end
