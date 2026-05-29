class ApplicationController < ActionController::API
  before_action :authenticate_user!

  attr_reader :current_user

  private

  def authenticate_user!
    header = request.headers["Authorization"]
    token = header&.split(" ")&.last

    decoded = JwtService.decode(token)

    if decoded.nil?
      return render json: { error: "Unauthorized" }, status: :unauthorized
    end

    @current_user = User.find_by(id: decoded[:user_id])

    render json: { error: "Unauthorized" }, status: :unauthorized unless @current_user
  end
end
