# frozen_string_literal: true

class AuthController < ApplicationController
  # skip auth for login endpoints
  skip_before_action :authenticate_user!, only: [ :login, :refresh ]

  def login
    user = User.find_by(email: params[:email])

    if user&.authenticate(params[:password])
      access_token = user.generate_jwt
      refresh_token = RefreshTokenService.generate(user)

      cookies.signed[:refresh_token] = {
        value: refresh_token,
        httponly: true,
        secure: Rails.env.production?,
        same_site: :strict
      }

      render json: {
        access_token: access_token,
        expires_in: 900
      }
    else
      render json: { error: "Invalid credentials" }, status: :unauthorized
    end
  end

  def refresh
    token = cookies.signed[:refresh_token]
    record = RefreshTokenService.find(token)

    if record.nil?
      return render json: { error: "Invalid refresh token" }, status: :unauthorized
    end

    user = record.user

    # rotate refresh token (IMPORTANT)
    RefreshTokenService.revoke(record)
    new_refresh = RefreshTokenService.generate(user)

    cookies.signed[:refresh_token] = {
      value: new_refresh,
      httponly: true,
      secure: Rails.env.production?,
      same_site: :strict
    }

    render json: {
      access_token: user.generate_jwt,
      expires_in: 900
    }
  end

  def logout
    token = cookies.signed[:refresh_token]
    record = RefreshTokenService.find(token)

    RefreshTokenService.revoke(record) if record

    cookies.delete(:refresh_token)

    render json: { message: "Logged out" }
  end
end
