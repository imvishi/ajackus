class AuthController < ApplicationController
  before_action :require_credentials!, only: %i[sign_up sign_in]
  before_action :require_user!, only: :sign_out

  rescue_from ClerkAuth::Error do |error|
    render json: { error: error.message }, status: error.status
  end

  # POST /auth/sign_up   body: { email, password }
  def sign_up
    user_id = ClerkAuth::SignUp.new(email: params[:email], password: params[:password]).call
    render json: { user_id: user_id }, status: :created
  end

  # POST /auth/sign_in   body: { email, password }
  def sign_in
    render json: ClerkAuth::SignIn.new(email: params[:email], password: params[:password]).call
  end

  # POST /auth/sign_out   header: Authorization: Bearer <token>
  def sign_out
    ClerkAuth::SignOut.new(session_id: clerk.session["sid"]).call
    head :no_content
  end

  private

  def require_credentials!
    return if params[:email].present? && params[:password].present?

    render json: { error: "email and password are required" }, status: :unprocessable_entity
  end
end
